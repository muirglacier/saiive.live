import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/from_account.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/wallet_static.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:defichainwallet/network/model/transaction_data.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';

import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'dart:math';

import 'package:tuple/tuple.dart';
import 'package:mutex/mutex.dart';

class Wallet extends IWallet {
  Map<int, IHdWallet> _wallets = Map<int, IHdWallet>();

  int _account;
  final ChainType _chain;
  ChainNet _network;

  String _password;
  String _seed;
  ApiService _apiService;
  IWalletDatabase _walletDatabase;

  bool _isInitialized = false;
  bool checkUtxo;

  final Mutex _walletMutex = Mutex();

  Wallet(this._chain, this.checkUtxo);

  void _isInitialzed() {
    if (!_isInitialized) {
      throw ArgumentError("Wallet is not initialized!");
    }
  }

  @override
  Future init() async {
    if (_isInitialized) {
      return;
    }
    _apiService = sl.get<ApiService>();
    _walletDatabase = sl.get<IWalletDatabase>();

    _password = ""; // TODO
    _seed = await sl.get<IVault>().getSeed();
    _network = await sl.get<SharedPrefsUtil>().getChainNetwork();
    _account = 0; //default account, for now only 0!

    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(_password, account, _chain, _network,
          mnemonicToSeedHex(_seed), _apiService);

      await wallet.init(_walletDatabase);

      _wallets.putIfAbsent(account.account, () => wallet);
    }

    _isInitialized = true;
  }

  @override
  Future close() async {
    _isInitialized = false;
  }

  @override
  void setWorkingAccount(int account) {
    _isInitialzed();
    _account = account;
  }

  @override
  Future<String> getPublicKey() async {
    _isInitialzed();
    return getPublicKeyFromAccount(_account, false);
  }

  Future<List<String>> getPublicKeys() async {
    _isInitialzed();
    List<String> keys = [];

    for (var wallet in _wallets.values) {
      keys.addAll(await wallet.getPublicKeys());
    }

    return keys;
  }

  @override
  Future<String> getPublicKeyFromAccount(
      int account, bool isChangeAddress) async {
    _isInitialzed();
    assert(_wallets.containsKey(account));

    if (_wallets.containsKey(account)) {
      return await _wallets[account]
          .nextFreePublicKey(_walletDatabase, isChangeAddress);
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> syncBalance() async {
    _isInitialzed();
    var startDate = DateTime.now();
    var ret = List<Account>.empty(growable: true);
    try {
      for (final wallet in _wallets.values) {
        var balance = await wallet.syncBalance();
        ret.addAll(balance);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      LogHelper.instance.e("error sync balance", e);
    }
    return ret;
  }

  @override
  Future<WalletAccount> addAccount(String name, int account) {
    _isInitialzed();
    return _walletDatabase.addAccount(
        name: name, account: account, chain: _chain);
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    _isInitialzed();
    return _walletDatabase.getAccounts();
  }

  @override
  Future<List<WalletAccount>> searchAccounts() async {
    _isInitialzed();

    var accounts = await getAccounts();
    accounts.sort((a, b) => a.id.compareTo(b.id));

    var accountIdList = accounts.map((e) => e.id).toList();

    var unusedAccounts = await WalletRestore.restore(
        _chain, _network, _seed, _password, _apiService,
        existingAccounts: accountIdList);

    unusedAccounts.sort((a, b) => a.id.compareTo(b.id));

    if (unusedAccounts.isEmpty) {
      var lastItem = accounts.last;

      unusedAccounts.add(WalletAccount(
          account: lastItem.account + 1,
          id: -1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) +
              (lastItem.account + 2).toString()));
    } else {
      var lastItem = unusedAccounts.last;

      unusedAccounts.add(WalletAccount(
          account: lastItem.account + 1,
          id: -1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) +
              " " +
              (lastItem.account + 2).toString()));
    }
    return unusedAccounts;
  }

  @override
  Future<TransactionData> createAndSend(
      int amount, String token, String to) async {
    _isInitialzed();

    if (_walletMutex.isLocked) {
      throw new ArgumentError(
          "Wallet sync is in progress, wait for it to finish....");
    }

    await _ensureUtxo();

    await _walletMutex.acquire();

    try {
      var txData = await createSendTransaction(amount, token, to);
      var tx = await createTxAndWait(txData.item1);

      await _walletDatabase.removeUnspentTransactions(txData.item2);
      return tx;
    } catch (error) {
      LogHelper.instance.e("Error creating tx...", error);
      throw error;
    } finally {
      _walletMutex.release();
    }
  }

  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount,
      String toToken, String to, int maxPrice, int maxPriceFraction) async {
    if (_walletMutex.isLocked) {
      throw new ArgumentError(
          "Wallet sync is in progress, wait for it to finish....");
    }
    await _ensureUtxo();

    await _walletMutex.acquire();

    try {
      var swap = await createSwap(
          fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction);

      return await createTxAndWait(swap.item1);
    } finally {
      _walletMutex.release();
    }
  }

  Future<Tuple2<String, List<tx.Transaction>>> createSwap(
      String fromToken,
      int fromAmount,
      String toToken,
      String to,
      int maxPrice,
      int maxPriceFraction) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      await prepareAccount(fromAmount);
    }

    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final fees = await getTxFee(1, 2);

    final fromTokenBalance = await _walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new ArgumentError("Insufficient balance...");
    }

    final fromTok = await _apiService.tokenService.getToken("DFI", fromToken);
    final toTok = await _apiService.tokenService.getToken("DFI", toToken);
    final fee = await getTxFee(0, 0);

    final fromAccounts =
        await _walletDatabase.getAccountBalancesForToken(fromToken);

    var inAmount = fromAmount;

    final txb = await _createBaseTransaction(0, to, changeAddress, fees,
        (txb, nw) async {
      for (var acc in fromAccounts) {
        await _getAuthInputsSmart(acc.address, fee);

        var useValue = min(inAmount, acc.balance);
        txb.addSwapOutput(fromTok.id, acc.address, useValue, toTok.id, to,
            maxPrice, maxPriceFraction);

        inAmount -= acc.balance;

        if (inAmount <= 0) {
          break;
        }
      }
    });

    return txb;
  }

  Future<Tuple2<String, List<tx.Transaction>>> createSendTransaction(
      int amount, String token, String to) async {
    final changeAddress = await this.getPublicKeyFromAccount(_account, true);

    if (DeFiConstants.isDfiToken(token)) {
      var minFee = await getTxFee(0, 0) + 10000;
      var txHex = await prepareAccountToUtxosTransactions(
          changeAddress, amount + minFee * 2);

      if (txHex != null) {
        final tx = await createTxAndWait(txHex.item1);

        await _walletDatabase.removeUnspentTransactions(txHex.item2);

        for (final unspentTx in tx.details.outputs) {
          if (unspentTx.address == changeAddress) {
            await _walletDatabase.addUnspentTransaction(unspentTx);
          }
        }
      }

      return await _createUtxoTransaction(amount, to, changeAddress);
    }
    return await _createAccountTransaction(token, amount, to);
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createAccountTransaction(
      String token, int amount, String to) async {
    if (DeFiConstants.isDfiToken(token)) {
      throw new ArgumentError(
          "$token not supported for account transactions...");
    }

    final tokenBalance = await _walletDatabase.getAccountBalance(token);

    if (amount > tokenBalance.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final tokenType = await _apiService.tokenService.getToken("DFI", token);
    final key = mnemonicToSeed(_seed);

    final accounts = await _walletDatabase.getAccountBalancesForToken(token);
    final useAccounts = List<FromAccount>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    var curAmount = 0;
    for (final tx in accounts) {
      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      final addressInfo = await _walletDatabase.getWalletAddress(tx.address);

      inputTxs.add(await _getAuthInputsSmart(tx.address, fee));

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          addressInfo.account,
          addressInfo.isChangeAddress,
          addressInfo.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));
      keys.add(keyPair);

      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final txb = await HdWalletUtil.buildAccountToAccountTransaction(
        inputTxs,
        useAccounts,
        keys,
        tokenType.id,
        to,
        amount,
        fee,
        changeAddress,
        _chain,
        _network);

    return Tuple2<String, List<tx.Transaction>>(txb.build().toHex(), inputTxs);
  }

  Future<Tuple2<String, List<tx.Transaction>>> createAuthTx(
      String pubKey) async {
    final changeAddress = await getPublicKeyFromAccount(_account, true);
    var baseTx = await _createBaseTransaction(200000, pubKey, changeAddress, 0,
        (txb, nw) {
      txb.addAuthOutput(outputIndex: 0);
    });

    return baseTx;
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createUtxoTransaction(
      int amount, String to, String changeAddress) async {
    final txb = await _createBaseTransaction(
        amount, to, changeAddress, 0, (txb, nw) => {});
    return txb;
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createBaseTransaction(
      int amount,
      String to,
      String changeAddress,
      int additionalFees,
      Function(TransactionBuilder, NetworkType) additional) async {
    final tokenBalance =
        await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (amount > tokenBalance?.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }
    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);

    final checkAmount =
        amount + 10000; //check for some more to have some room for fees

    var curAmount = 0.0;
    for (final tx in unspentTxs) {
      if (!await _walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await _walletDatabase.getWalletAddress(tx.address);

      if (tx.value <= 0) {
        //ignore auth txs
        continue;
      }
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          address.account,
          address.isChangeAddress,
          address.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }

    final fees = await getTxFee(useTxs.length, 2);

    if (curAmount < (checkAmount - fees)) {
      throw new ArgumentError("Insufficent funds");
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, to, amount,
        fees, changeAddress, additional, _chain, _network);
    return Tuple2<String, List<tx.Transaction>>(txb, useTxs);
  }

  Future<tx.Transaction> _getAuthInputsSmart(String pubKey, int minFee) async {
    var authTxs =
        await _walletDatabase.getUnspentTransactionsForPubKey(pubKey, minFee);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    var txHex = await createAuthTx(pubKey);

    var txData = await createTxAndWait(txHex.item1);
    final retOut = txData.details.outputs.firstWhere(
        (element) => element.spentHeight <= 0 && element.address == pubKey);

    if (retOut != null) {
      _walletDatabase.removeUnspentTransactions(txHex.item2);
      for (var out in txData.details.outputs) {
        await _walletDatabase.addUnspentTransaction(out);
      }
    }
    return retOut;
  }

  Future<TransactionData> createTxAndWait(String txHex) async {
    final txId =
        await _apiService.transactionService.sendRawTransaction("DFI", txHex);

    final r = RetryOptions(maxAttempts: 15, maxDelay: Duration(seconds: 5));
    final response = await r.retry(
        () async {
          return await _apiService.transactionService.getWithTxId("DFI", txId);
        },
        retryIf: (e) => e is HttpException || e is ErrorResponse,
        onRetry: (e) {
          LogHelper.instance.e("error get tx", e);
        });

    return response;
  }

  @override
  Future<tx.Transaction> getTransaction(String id) async {
    return await _walletDatabase.getTransaction(id);
  }

  Future<int> getTxFee(int inputs, int outputs) async {
    if (inputs == 0 && outputs == 0)
      return 3000; //default fee is always the same for now
    return (inputs * 180) + (outputs * 34) + 50;
  }

  Future<Tuple2<String, List<tx.Transaction>>>
      prepareAccountToUtxosTransactions(String pubKey, int amount) async {
    var tokenBalance =
        await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError(
          "Token balance must be greater than 0 to create any tx!");
    }
    // we have currently enough utxo
    if (tokenBalance.balance > amount) {
      return null;
    }

    var accountBalance = await _walletDatabase
        .getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    var neededUtxo = amount - tokenBalance.balance;

    final accounts = await _walletDatabase
        .getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }
    final key = mnemonicToSeed(_seed);

    final neededAccounts = List<Account>.empty(growable: true);
    final fees = await getTxFee(0, 0);
    final useInputs = List<tx.Transaction>.empty(growable: true);
    var accBalance = 0;

    final keys = List<ECPair>.empty(growable: true);

    for (final acc in accounts) {
      neededAccounts.add(acc);

      final tx = await _getAuthInputsSmart(acc.address, fees);

      useInputs.add(tx);

      _walletDatabase.addUnspentTransaction(tx);
      _walletDatabase.setAccountBalance(Account(
          token: DeFiConstants.DefiTokenSymbol,
          address: acc.address,
          balance: acc.balance,
          chain: acc.chain,
          network: acc.network));

      if (!await _walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await _walletDatabase.getWalletAddress(tx.address);

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          address.account,
          address.isChangeAddress,
          address.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if ((accBalance + acc.balance) >= neededUtxo) {
        break;
      }
      accBalance += acc.balance;
    }

    final tokenType = await _apiService.tokenService
        .getToken("DFI", DeFiConstants.DefiAccountSymbol);

    var txHex = await HdWalletUtil.buildTransaction(
        useInputs, keys, pubKey, 0, fees, pubKey, (txb, network) async {
      final mintingStartsAt = txb.tx.ins.length + neededAccounts.length;
      for (final acc in neededAccounts) {
        var needAmount = min(neededUtxo, acc.balance);

        txb.addAccountToUtxoOutput(
            tokenType.id, acc.address, needAmount, mintingStartsAt);
        txb.addOutput(pubKey, needAmount);
        neededUtxo -= needAmount;
        if (neededUtxo <= 0) {
          break;
        }
      }
    }, _chain, _network);

    return Tuple2<String, List<tx.Transaction>>(txHex, useInputs);
  }

  Future<TransactionData> prepareAccount(int amount) async {
    final txHex = await prepareUtxoToAccountTransaction(amount);
    if (txHex != null) {
      var txData = await createTxAndWait(txHex.item1);

      _walletDatabase.removeUnspentTransactions(txHex.item2);
      for (var out in txData.details.outputs) {
        if (await _walletDatabase.isOwnAddress(out.address)) {
          await _walletDatabase.addUnspentTransaction(out);
        }
      }

      return txData;
    }
    return null;
  }

  Future<Tuple2<String, List<tx.Transaction>>> prepareUtxoToAccountTransaction(
      int amount) async {
    final tokenBalance =
        await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    final accBalance = await _walletDatabase
        .getAccountBalance(DeFiConstants.DefiAccountSymbol);

    final totalBalance = tokenBalance.balance + accBalance.balance;

    if (amount > totalBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    if (accBalance.balance > amount) {
      // we already have enough acc balance
      return null;
    }

    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    var checkAmount = (amount - accBalance.balance) + fee;

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      if (!await _walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await _walletDatabase.getWalletAddress(tx.address);

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          address.account,
          address.isChangeAddress,
          address.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }
    final changeAddress = await getPublicKeyFromAccount(_account, true);

    final tokenType = await _apiService.tokenService
        .getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = await _createBaseTransaction(
        0, changeAddress, changeAddress, fee + checkAmount, (txb, nw) {
      for (var input in useTxs) {
        var needAmount = min(checkAmount, input.value);

        txb.addUtxosToAccountOutput(
            tokenType.id, input.address, needAmount, nw);

        checkAmount -= needAmount;

        if (checkAmount <= 0) {
          break;
        }
      }
    });
    return txs;
  }

  Future _ensureUtxo() async {
    await _walletMutex.acquire();
    try {
      if (checkUtxo) {
        await _syncUnspentTransactionOutputs();
      }
    } finally {
      _walletMutex.release();
    }
  }

  Future _syncUnspentTransactionOutputs() async {
    _isInitialzed();

    var dataMap = Map();
    dataMap["chain"] = _chain;
    dataMap["network"] = _network;
    dataMap["seed"] = await sl.get<IVault>().getSeed();
    dataMap["password"] = ""; //await sl.get<Vault>().getSecret();
    dataMap["apiService"] = sl.get<ApiService>();
    dataMap["accounts"] = await sl.get<IWalletDatabase>().getAccounts();

    var utxos = await compute(WalletStaticHelper.syncUtxo, dataMap);

    await _walletDatabase.clearUnspentTransactions();

    for (final tx in utxos) {
      if (tx.spentTxId == null || tx.spentTxId.isEmpty) {
        await _walletDatabase.addUnspentTransaction(tx);
      }
    }

    var balances = await compute(WalletStaticHelper.syncWallet, dataMap);

    await _walletDatabase.clearAccountBalances();

    for (final balance in balances) {
      _walletDatabase.setAccountBalance(balance);
    }
  }

  Future _syncTransactions() async {
    await _walletMutex.acquire();
    try {
      var dataMap = Map();
      dataMap["chain"] = _chain;
      dataMap["network"] = _network;
      dataMap["seed"] = await sl.get<IVault>().getSeed();
      dataMap["password"] = ""; //await sl.get<Vault>().getSecret();
      dataMap["apiService"] = sl.get<ApiService>();
      dataMap["accounts"] = await sl.get<IWalletDatabase>().getAccounts();

      var txs = await compute(WalletStaticHelper.syncTransactions, dataMap);
      await _walletDatabase.clearTransactions();

      for (tx.Transaction transaction in txs) {
        await _walletDatabase.addTransaction(transaction);
      }
    } finally {
      _walletMutex.release();
    }
  }

  Future syncAll() async {
    await _ensureUtxo();
    await _syncTransactions();
  }
}
