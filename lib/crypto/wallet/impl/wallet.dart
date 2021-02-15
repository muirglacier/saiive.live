import 'dart:typed_data';

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
import 'package:defichainwallet/network/model/balance.dart';
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

  Wallet(this._chain, this.checkUtxo);

  void _isInitialzed() {
    if (!_isInitialized) {
      throw ArgumentError("Wallet is not initialized!");
    }
  }

  @override
  Future init() async {
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

      _wallets.putIfAbsent(account.account, () => wallet);
    }

    _isInitialized = true;
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
    var ret = List<Account>();
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
    var txData = await createSendTransaction(amount, token, to);

    try {
      var tx = await createTxAndWait(txData.item1);

      await _walletDatabase.removeUnspentTransactions(txData.item2);
      return tx;
    } catch (error) {
      LogHelper.instance.e("Error creating tx...", error);
      throw error;
    }
  }

  Future<Tuple2<String, List<tx.Transaction>>> createSendTransaction(
      int amount, String token, String to) async {
    _isInitialzed();
    await _ensureUtxo();

    final changeAddressRaw =
        await _wallets[_account].nextFreePublicKeyRaw(_walletDatabase, true);

    var changeAddress = await HdWalletUtil.getPublicKey(
        mnemonicToSeed(_seed),
        changeAddressRaw.item1,
        changeAddressRaw.item2,
        changeAddressRaw.item3,
        _chain,
        _network);

    if (token == DeFiConstants.DefiTokenSymbol ||
        token == DeFiConstants.DefiAccountSymbol) {
      var txHex =
          await prepareAccountToUtxosTransactions(changeAddress, amount);
      if (txHex != null) {
        final tx = await createTxAndWait(txHex.item1);

        await _walletDatabase.removeUnspentTransactions(txHex.item2);

        for (final unspentTx in tx.details.outputs
            .where((element) => element.address == changeAddress)) {
          unspentTx.account = changeAddressRaw.item1;
          unspentTx.isChangeAddress = true;
          unspentTx.index = changeAddressRaw.item3;

          await _walletDatabase.addUnspentTransaction(unspentTx);
        }
      }

      return await _createUtxoTransaction(amount, to, changeAddress);
    }
    return await _createAccountTransaction(token, amount, to);
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createAccountTransaction(
      String token, int amount, String to) async {
    if (token == DeFiConstants.DefiAccountSymbol ||
        token == DeFiConstants.DefiTokenSymbol) {
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
    final fee = await getTxFee();

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    var curAmount = 0;
    for (final tx in accounts) {
      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      inputTxs.add(await _getAuthInputsSmart(
          key, tx.index, tx.isChangeAddress, tx.index, fee));

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
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
    final fee = await getTxFee();
    var baseTx = await _createBaseTransaction(
        200000, pubKey, changeAddress, fee, (txb, nw) {
      txb.addAuthOutput(outputIndex: 0);
    });

    return baseTx;
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createUtxoTransaction(
      int amount, String to, String changeAddress) async {
    final fee = await getTxFee();
    final txb = await _createBaseTransaction(
        amount, to, changeAddress, fee, (txb, nw) => {});
    return txb;
  }

  Future<Tuple2<String, List<tx.Transaction>>> _createBaseTransaction(
      int amount,
      String to,
      String changeAddress,
      int fees,
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

    final checkAmount = amount + fees;

    var curAmount = 0.0;
    for (final tx in unspentTxs) {
      if (tx.value <= 0) {
        //ignore auth txs
        continue;
      }
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }

    if(curAmount < checkAmount) {
      throw new ArgumentError("Insufficent funds");
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, to, amount,
        fees, changeAddress, additional, _chain, _network);
    return Tuple2<String, List<tx.Transaction>>(txb, useTxs);
  }

  Future<tx.Transaction> _getAuthInputsSmart(Uint8List seed, int account,
      bool isChangeAddress, int index, int minFee) async {
    var pubKey = await HdWalletUtil.getPublicKey(
        seed, account, isChangeAddress, index, _chain, _network);
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
      retOut.account = account;
      retOut.index = index;
      retOut.isChangeAddress = isChangeAddress;

      _walletDatabase.removeUnspentTransactions(txHex.item2);
      for (var out in txData.details.outputs) {
        _walletDatabase.addUnspentTransaction(out);
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

  Future<int> getTxFee() async {
    return 1000;
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
    final fees = await getTxFee();
    final useInputs = List<tx.Transaction>.empty(growable: true);
    var accBalance = 0;

    final keys = List<ECPair>.empty(growable: true);

    for (final acc in accounts) {
      neededAccounts.add(acc);

      final tx = await _getAuthInputsSmart(
          key, acc.index, acc.isChangeAddress, acc.index, fees);

      useInputs.add(tx);

      _walletDatabase.addUnspentTransaction(tx);
      _walletDatabase.setAccountBalance(Account(
          token: DeFiConstants.DefiTokenSymbol,
          account: acc.account,
          address: acc.address,
          balance: acc.balance,
          chain: acc.chain,
          index: acc.index,
          isChangeAddress: acc.isChangeAddress,
          network: acc.network));

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
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
            tokenType.id, acc.address, needAmount, mintingStartsAt, network);
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
    return await createTxAndWait(txHex.item1);
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
    final fee = await getTxFee();

    var checkAmount = (amount - accBalance.balance) + fee;

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
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
    if (!checkUtxo) {
      return;
    }
    await _syncUnspentTransactionOutputs();
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
    var dataMap = Map();
    dataMap["chain"] = _chain;
    dataMap["network"] = _network;
    dataMap["seed"] = await sl.get<IVault>().getSeed();
    dataMap["password"] = ""; //await sl.get<Vault>().getSecret();
    dataMap["apiService"] = sl.get<ApiService>();
    dataMap["accounts"] = await sl.get<IWalletDatabase>().getAccounts();

    var txs = await compute(WalletStaticHelper.syncTransactions, dataMap);
    await _walletDatabase.clearUnspentTransactions();

    for (tx.Transaction transaction in txs) {
      await _walletDatabase.addTransaction(transaction);
    }
  }

  Future syncAll() async {
    await _ensureUtxo();
    await _syncTransactions();
  }
}
