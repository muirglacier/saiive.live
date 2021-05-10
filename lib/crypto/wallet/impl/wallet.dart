import 'dart:async';
import 'dart:typed_data';
import 'dart:core';

import 'package:async/async.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/from_account.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/errors/MempoolConflictError.dart';
import 'package:defichainwallet/crypto/errors/MissingInputsError.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
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
import 'package:retry/retry.dart';
import 'dart:math';

import 'package:tuple/tuple.dart';
import 'package:mutex/mutex.dart';

class Wallet extends IWallet {
  Map<int, IHdWallet> _wallets = Map<int, IHdWallet>();

  int _account;
  final ChainType _chain;
  ChainNet _network;

  SharedPrefsUtil _sharedPrefsUtil;

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
    _sharedPrefsUtil = sl.get<SharedPrefsUtil>();
    _network = await _sharedPrefsUtil.getChainNetwork();
    _account = 0; //default account, for now only 0!

    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(_password, account, _chain, _network, mnemonicToSeedHex(_seed), _apiService);

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
  bool isLocked() {
    return _walletMutex.isLocked;
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
      keys.addAll(await wallet.getPublicKeys(_walletDatabase));
    }

    return keys;
  }

  @override
  Future<String> getPublicKeyFromAccount(int account, bool isChangeAddress) async {
    _isInitialzed();
    assert(_wallets.containsKey(account));

    if (_wallets.containsKey(account)) {
      return await _wallets[account].nextFreePublicKey(_walletDatabase, _sharedPrefsUtil, isChangeAddress);
    }
    throw UnimplementedError();
  }

  @override
  Future<WalletAccount> addAccount(String name, int account) {
    _isInitialzed();
    return _walletDatabase.addAccount(name: name, account: account, chain: _chain);
  }

  Future<bool> hasAccounts() async {
    _isInitialzed();
    final acc = await _walletDatabase.getAccounts();
    return acc.isNotEmpty;
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    _isInitialzed();
    return _walletDatabase.getAccounts();
  }

  @override
  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> searchAccounts() async {
    _isInitialzed();

    var accounts = await getAccounts();
    accounts.sort((a, b) => a.id.compareTo(b.id));

    var accountIdList = accounts.map((e) => e.id).toList();
    var unusedAccounts = await WalletRestore.restore(_chain, _network, _seed, _password, _apiService, existingAccounts: accountIdList);
    unusedAccounts.item1.sort((a, b) => a.id.compareTo(b.id));

    if (unusedAccounts.item1.isEmpty) {
      var lastItem = accounts.last;
      unusedAccounts.item1.add(WalletAccount(account: lastItem.account + 1, id: -1, chain: _chain, name: ChainHelper.chainTypeString(_chain) + (lastItem.account + 2).toString()));
    } else {
      var lastItem = unusedAccounts.item1.last;
      unusedAccounts.item1
          .add(WalletAccount(account: lastItem.account + 1, id: -1, chain: _chain, name: ChainHelper.chainTypeString(_chain) + " " + (lastItem.account + 2).toString()));
    }
    return unusedAccounts;
  }

  @override
  Future<TransactionData> createAndSend(int amount, String token, String to, {StreamController<String> loadingStream}) async {
    _isInitialzed();

    loadingStream?.add(S.current.wallet_operation_refresh_utxo);
    await _ensureUtxo(loadingStream: loadingStream);

    await _walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var txData = await createSendTransaction(amount, token, to);

      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(txData);

      await _walletDatabase.removeUnspentTransactions(txData.item2);
      return tx;
    } catch (error) {
      if (error is HttpException) {
        LogHelper.instance.e("Error creating tx..." + error.error.error, error.error);
        throw error.error;
      }
      LogHelper.instance.e("Error creating tx...", error);
      throw error;
    } finally {
      _walletMutex.release();
    }
  }

  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {StreamController<String> loadingStream}) async {
    await _ensureUtxo(loadingStream: loadingStream);
    await _walletMutex.acquire();

    try {
      var addLiq = await addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await _createTxAndWait(addLiq, loadingStream: loadingStream);
    } finally {
      _walletMutex.release();
    }
  }

  Future<String> addPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream}) async {
    if (!DeFiConstants.isDfiToken(tokenA) && !DeFiConstants.isDfiToken(tokenB)) {
      throw ArgumentError("One of the 2 tokens must be DFI!");
    }

    await prepareAccount(DeFiConstants.isDfiToken(tokenA) ? amountA : amountB);

    final tokenABalance = await _walletDatabase.getAccountBalance(tokenA);
    final tokenBBalance = await _walletDatabase.getAccountBalance(tokenB);

    if (tokenABalance.balance < amountA) {
      throw new ArgumentError("Insufficient balance...");
    }

    if (tokenBBalance.balance < amountB) {
      throw new ArgumentError("Insufficient balance...");
    }

    final tokenAType = await _apiService.tokenService.getToken("DFI", tokenA);
    final tokenBType = await _apiService.tokenService.getToken("DFI", tokenB);
    final key = mnemonicToSeed(_seed);

    final accountsA = await _walletDatabase.getAccountBalancesForToken(tokenA);
    final accountsB = await _walletDatabase.getAccountBalancesForToken(tokenB);

    final fee = await getTxFee(0, 0);

    final accountA = await _getNeededAccounts(accountsA, amountA);
    final accountB = await _getNeededAccounts(accountsB, amountB, excludeAddresses: accountA.item1.map((e) => e.address).toList());

    if (accountA.item1.length == accountB.item1.length) {
      var inputTxs = List<tx.Transaction>.empty(growable: true);
      inputTxs.addAll(accountA.item2);

      for (final input in accountB.item2) {
        if (!inputTxs.any((element) => element.mintTxId == input.mintTxId && element.mintHeight == input.mintHeight)) {
          inputTxs.add(input);
        }
      }

      final txb = await HdWalletUtil.buildAddPollLiquidityTransaction(
          inputTxs, accountA.item1, accountB.item1, _walletDatabase, tokenAType.id, tokenBType.id, shareAddress, amountA, amountB, fee, shareAddress, key, _chain, _network);
      return txb.build().toHex();
    } else {
      final firstTokenA = accountA.item1.first;
      for (int i = 1; i < accountA.item1.length; i++) {
        final token = accountA.item1[i];
        var tx = await _createAccountTransaction(tokenA, token.amount, firstTokenA.address);
        await createTxAndWait(tx, loadingStream: loadingStream);
      }
      final firstTokenB = accountB.item1.first;
      for (int i = 1; i < accountB.item1.length; i++) {
        final token = accountB.item1[i];
        var tx = await _createAccountTransaction(tokenB, token.amount, firstTokenB.address);
        await createTxAndWait(tx, loadingStream: loadingStream);
      }

      //try again
      await _ensureUtxo(loadingStream: loadingStream);
      return addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress);
    }
  }

  Future<Tuple2<List<FromAccount>, List<tx.Transaction>>> _getNeededAccounts(List<Account> accounts, int amount, {List<String> excludeAddresses}) async {
    var curAmount = 0;
    var useAccounts = List<FromAccount>.empty(growable: true);
    final fees = await getTxFee(1, 2) + 5000;
    final inputTxs = List<tx.Transaction>.empty(growable: true);

    for (final tx in accounts) {
      if (excludeAddresses != null && excludeAddresses.contains(tx.address)) {
        continue;
      }

      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      inputTxs.add(await _getAuthInputsSmart(tx.address, fees));
      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    return Tuple2(useAccounts, inputTxs);
  }

  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    await _ensureUtxo(loadingStream: loadingStream);
    await _walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_create_swap_tx);
      var swap = await createSwap(fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, loadingStream: loadingStream);

      return tx;
    } finally {
      _walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      await prepareAccount(fromAmount);
    }

    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final fees = await getTxFee(1, 2) + 5000;

    final fromTokenBalance = await _walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new ArgumentError("Insufficient balance...");
    }

    final fromTok = await _apiService.tokenService.getToken("DFI", fromToken);
    final toTok = await _apiService.tokenService.getToken("DFI", toToken);
    final fromAccounts = await _walletDatabase.getAccountBalancesForToken(fromToken);

    var inAmount = fromAmount;
    final key = mnemonicToSeed(_seed);

    for (var acc in fromAccounts) {
      await _getAuthInputsSmart(acc.address, fees);
      inAmount -= acc.balance;

      if (inAmount <= 0) {
        break;
      }
    }
    inAmount = fromAmount;

    final txb = await _createBaseTransaction(0, to, changeAddress, fees, (txb, inputTxs, nw) async {
      for (var acc in fromAccounts) {
        var tx = await _getAuthInputsSmart(acc.address, fees);

        var useValue = min(inAmount, acc.balance);
        txb.addSwapOutput(fromTok.id, acc.address, useValue, toTok.id, to, maxPrice, maxPriceFraction);

        final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
        if (inputContainsAuthTx.isEmpty) {
          final addressInfo = await _walletDatabase.getWalletAddress(tx.address);

          final keyPair = HdWalletUtil.getKeyPair(
              key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

          var vin = txb.addInput(tx.mintTxId, tx.mintIndex);
          txb.addOutput(tx.address, tx.value);
          final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
          final redeemScript = p2wpkh.output;

          txb.sign(vin: vin, keyPair: keyPair, witnessValue: tx.value, redeemScript: redeemScript);
        }

        inAmount -= acc.balance;

        if (inAmount <= 0) {
          break;
        }
      }
    });

    return txb;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createSendTransaction(int amount, String token, String to) async {
    final changeAddress = await this.getPublicKeyFromAccount(_account, true);

    if (DeFiConstants.isDfiToken(token)) {
      var txHex = await prepareAccountToUtxosTransactions(changeAddress, amount);

      if (txHex != null) {
        for (var txHexStr in txHex.item1) {
          final tx = await _createTxAndWait(txHexStr);

          for (final unspentTx in tx.details.outputs) {
            if (unspentTx.address == changeAddress) {
              await _walletDatabase.addUnspentTransaction(unspentTx);
            }
          }
        }
        await _walletDatabase.removeUnspentTransactions(txHex.item2);
        amount -= txHex.item3;
      }

      return await _createUtxoTransaction(amount, to, changeAddress);
    }
    return await _createAccountTransaction(token, amount, to);
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createAccountTransaction(String token, int amount, String to) async {
    if (DeFiConstants.isDfiToken(token)) {
      throw new ArgumentError("$token not supported for account transactions...");
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

      final keyPair = HdWalletUtil.getKeyPair(key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, addressInfo.chain, addressInfo.network);
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
    final txb = await HdWalletUtil.buildAccountToAccountTransaction(inputTxs, useAccounts, keys, tokenType.id, to, amount, fee, changeAddress, _chain, _network);

    return Tuple3<String, List<tx.Transaction>, String>(txb.build().toHex(), inputTxs, changeAddress);
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createAuthTx(String pubKey, {StreamController<String> loadingStream}) async {
    final changeAddress = await getPublicKeyFromAccount(_account, true);
    var baseTx = await _createBaseTransaction(200000, pubKey, changeAddress, 0, (txb, inputTxs, nw) {
      txb.addAuthOutput(outputIndex: 0);
    });
    loadingStream?.add(S.current.wallet_operation_create_auth_tx);
    return baseTx;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createUtxoTransaction(int amount, String to, String changeAddress) async {
    final txb = await _createBaseTransaction(amount, to, changeAddress, 0, (txb, inputTxs, nw) => {});
    return txb;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createBaseTransaction(
      int amount, String to, String changeAddress, int additionalFees, Function(TransactionBuilder, List<tx.Transaction>, NetworkType) additional) async {
    final tokenBalance = await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (amount > tokenBalance?.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }
    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);

    final checkAmount = amount + 10000;

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

      final keyPair = HdWalletUtil.getKeyPair(key, address.account, address.isChangeAddress, address.index, address.chain, address.network);

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }

    var fees = await getTxFee(useTxs.length, 2);
    fees += additionalFees;

    if (amount == tokenBalance?.balance) {
      amount -= fees;
    }

    if (curAmount < (checkAmount - fees)) {
      throw new ArgumentError("Insufficent funds");
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, to, amount, fees, changeAddress, additional, _chain, _network);
    return Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, changeAddress);
  }

  Future<tx.Transaction> _getAuthInputsSmart(String pubKey, int minFee, {StreamController<String> loadingStream}) async {
    var authTxs = await _walletDatabase.getUnspentTransactionsForPubKey(pubKey, minFee);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    var txHex = await createAuthTx(pubKey, loadingStream: loadingStream);
    var txData = await createTxAndWait(txHex, loadingStream: loadingStream);
    final retOut = txData.details.outputs.firstWhere((element) => element.spentHeight <= 0 && element.address == pubKey);

    return retOut;
  }

  Future<TransactionData> createTxAndWait(Tuple3<String, List<tx.Transaction>, String> tx, {StreamController<String> loadingStream}) async {
    final txHex = tx.item1;
    final response = await _createTxAndWait(txHex, loadingStream: loadingStream);

    LogHelper.instance.i("Remove unspent txs " + tx.item2.map((e) => e.uniqueId).join(" - "));
    await _walletDatabase.removeUnspentTransactions(tx.item2);
    for (var out in response.details.outputs) {
      if (await _walletDatabase.isOwnAddress(out.address)) {
        await _walletDatabase.addUnspentTransaction(out);

        LogHelper.instance.i("Add unspent tx " + out.uniqueId);
      }
    }

    // debug only
    final unspentTx = await _walletDatabase.getUnspentTransactions();
    for (final unspent in unspentTx) {
      LogHelper.instance.i("Unspent tx: " + unspent.uniqueId);
    }

    return response;
  }

  Future<TransactionData> _createTxAndWait(String txHex, {StreamController<String> loadingStream}) async {
    final r = RetryOptions(maxAttempts: 15, maxDelay: Duration(seconds: 15));
    // bool ensureUtxoCalled = false;

    LogHelper.instance.d("commiting tx $txHex");
    try {
      final txId = await r.retry(() async {
        return await _apiService.transactionService.sendRawTransaction("DFI", txHex);
      }, retryIf: (e) async {
        if (e is HttpException) {
          if (e.error.error.contains("txn-mempool-conflict")) {
            loadingStream?.add(S.current.wallet_operation_mempool_conflict_retry);
            return true;
          }
          // if (e.error.error.contains("Missing inputs") && !ensureUtxoCalled) {
          //   ensureUtxoCalled = true;
          //   await _ensureUtxo(loadingStream: loadingStream);
          //   return true;
          // }
          return false;
        }
        return false;
      }, onRetry: (e) {
        LogHelper.instance.e("error create tx", e);
      });

      LogHelper.instance.i("commited tx with id " + txId);

      final response = await r.retry(() async {
        return await _apiService.transactionService.getWithTxId("DFI", txId);
      }, retryIf: (e) {
        if (e is HttpException || e is ErrorResponse) return true;
        return false;
      }, onRetry: (e) {
        LogHelper.instance.e("error get tx", e);
      });

      return response;
    } catch (e) {
      if (e is HttpException) {
        if (e.error.error.contains("txn-mempool-conflict")) {
          throw new MemPoolConflictError(S.current.wallet_operation_mempool_conflict);
        }
        if (e.error.error.contains("Missing inputs")) {
          throw new MissingInputsError(S.current.wallet_operation_missing_inputs);
        }
      }

      throw e;
    }
  }

  @override
  Future<tx.Transaction> getTransaction(String id) async {
    return await _walletDatabase.getTransaction(id);
  }

  Future<int> getTxFee(int inputs, int outputs) async {
    if (inputs == 0 && outputs == 0) return 3000; //default fee is always the same for now
    return (inputs * 180) + (outputs * 34) + 50;
  }

  Future<Tuple3<List<String>, List<tx.Transaction>, int>> prepareAccountToUtxosTransactions(String pubKey, int amount) async {
    var tokenBalance = await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }
    // we have currently enough utxo
    if (tokenBalance.balance > amount) {
      return null;
    }

    var accountBalance = await _walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    var neededUtxo = amount - tokenBalance.balance;
    final accounts = await _walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }
    final key = mnemonicToSeed(_seed);
    final usedInputs = List<tx.Transaction>.empty(growable: true);
    final fees = await getTxFee(0, 0);

    var accBalance = 0;

    final tokenType = await _apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = List<String>.empty(growable: true);

    for (final acc in accounts) {
      final useInputs = List<tx.Transaction>.empty(growable: true);
      final keys = List<ECPair>.empty(growable: true);

      final authTx = await _getAuthInputsSmart(acc.address, fees);
      useInputs.add(authTx);
      usedInputs.add(authTx);

      _walletDatabase.addUnspentTransaction(authTx);
      _walletDatabase.setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: acc.address, balance: acc.balance, chain: acc.chain, network: acc.network));

      if (!await _walletDatabase.isOwnAddress(authTx.address)) {
        continue;
      }

      final address = await _walletDatabase.getWalletAddress(authTx.address);
      final keyPair = HdWalletUtil.getKeyPair(
          key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(authTx.chain), ChainHelper.networkFromString(authTx.network));

      keys.add(keyPair);
      var useAcc = acc;

      if ((accBalance + acc.balance) >= neededUtxo) {
        var neededAccBalance = min(acc.balance, neededUtxo - accBalance);
        accBalance += neededAccBalance;
        useAcc = Account(address: acc.address, balance: neededAccBalance, chain: acc.chain, network: acc.network, raw: acc.raw, token: acc.token);
      } else {
        useAcc = acc;
        accBalance += acc.balance;
      }

      var txHex = await HdWalletUtil.buildTransaction(useInputs, keys, pubKey, 0, fees, pubKey, (txb, inputTxs, network) async {
        final mintingStartsAt = txb.tx.ins.length + 1;

        txb.addOutput(pubKey, useAcc.balance);
        txb.addAccountToUtxoOutput(tokenType.id, acc.address, useAcc.balance, mintingStartsAt);
      }, _chain, _network);

      txs.add(txHex);

      if (accBalance > neededUtxo) {
        break;
      }
    }

    if (accBalance < neededUtxo) {
      throw new ArgumentError("should not happen at all now...");
    }

    return Tuple3(txs, usedInputs, fees * txs.length);
  }

  Future<TransactionData> prepareAccount(int amount, {StreamController<String> loadingStream}) async {
    final txHex = await prepareUtxoToAccountTransaction(amount, loadingStream: loadingStream);
    if (txHex != null) {
      var txData = await createTxAndWait(txHex, loadingStream: loadingStream);

      for (var input in txData.details.inputs) {
        if (await _walletDatabase.isOwnAddress(input.address)) {
          final accBalance = new Account(
              address: input.address,
              balance: amount,
              token: DeFiConstants.DefiAccountSymbol,
              chain: ChainHelper.chainTypeString(_chain),
              network: ChainHelper.chainNetworkString(_network));
          await _walletDatabase.setAccountBalance(accBalance);
        }
      }

      return txData;
    }
    return null;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> prepareUtxoToAccountTransaction(int amount, {StreamController<String> loadingStream}) async {
    final tokenBalance = await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    final accBalance = await _walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);

    final accountBalance = accBalance.balance != null ? accBalance.balance : 0;
    final totalBalance = (tokenBalance.balance != null ? tokenBalance.balance : 0) + accountBalance;

    if (amount > totalBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    if (accountBalance > amount) {
      // we already have enough acc balance
      return null;
    }
    loadingStream?.add(S.current.wallet_operation_create_pepare_acc_tx);

    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    var checkAmount = (amount - accountBalance) + fee;

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      if (!await _walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await _walletDatabase.getWalletAddress(tx.address);
      final keyPair =
          HdWalletUtil.getKeyPair(key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }
    final changeAddress = await getPublicKeyFromAccount(_account, true);

    final tokenType = await _apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = await _createBaseTransaction(0, changeAddress, changeAddress, fee + checkAmount, (txb, inputTxs, nw) {
      for (var input in useTxs) {
        var needAmount = min(checkAmount, input.value);

        txb.addUtxosToAccountOutput(tokenType.id, input.address, needAmount, nw);

        checkAmount -= needAmount;

        if (checkAmount <= 0) {
          break;
        }
      }
    });
    return txs;
  }

  Future _ensureUtxo({StreamController<String> loadingStream}) async {
    await _walletMutex.acquire();

    try {
      for (final wallet in _wallets.values) {
        await wallet.syncWallet(_walletDatabase, loadingStream: loadingStream);
      }
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    } finally {
      _walletMutex.release();
    }
  }

  Future _syncTransactions({StreamController<String> loadingStream}) async {
    await _walletMutex.acquire();

    try {
      for (final wallet in _wallets.values) {
        await wallet.syncWalletTransactions(_walletDatabase, loadingStream: loadingStream);
      }
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    } finally {
      _walletMutex.release();
    }
  }

  Future _syncAll({StreamController<String> loadingStream}) async {
    await _ensureUtxo(loadingStream: loadingStream);
    await _syncTransactions(loadingStream: loadingStream);
  }

  Future syncAll({StreamController<String> loadingStream}) async {
    await _syncAll(loadingStream: loadingStream);
  }
}
