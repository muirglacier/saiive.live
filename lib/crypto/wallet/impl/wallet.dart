import 'dart:async';
import 'dart:core';
import 'dart:typed_data';

import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/errors/MempoolConflictError.dart';
import 'package:saiive.live/crypto/errors/MissingInputsError.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/hdWallet.dart';
import 'package:saiive.live/crypto/wallet/impl/hdWallet.dart';
import 'package:saiive.live/crypto/wallet/wallet-restore.dart';
import 'package:saiive.live/crypto/wallet/wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/network/model/transaction.dart' as tx;
import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:retry/retry.dart';

import 'package:tuple/tuple.dart';
import 'package:mutex/mutex.dart';
import 'package:uuid/uuid.dart';

abstract class Wallet extends IWallet {
  Map<String, IHdWallet> _wallets = Map<String, IHdWallet>();

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

  @protected
  Uint8List seedList;

  @protected
  final Mutex walletMutex = Mutex();

  @protected
  String get seed => _seed;

  @protected
  IWalletDatabase get walletDatabase => _walletDatabase;

  @protected
  ApiService get apiService => _apiService;

  @protected
  int get account => _account;

  @protected
  ChainType get chain => _chain;

  @protected
  ChainNet get network => _network;

  Wallet(this._chain, this.checkUtxo);

  @protected
  void isInitialzed() {
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
    _sharedPrefsUtil = sl.get<SharedPrefsUtil>();

    _network = await _sharedPrefsUtil.getChainNetwork();
    _walletDatabase = await sl.get<IWalletDatabaseFactory>().getDatabase(_chain, _network);

    _password = "";
    _seed = await sl.get<IVault>().getSeed();
    _account = 0; //default account, for now only 0!

    seedList = await compute(mnemonicToSeed, seed);

    final seedHex = await compute(mnemonicToSeedHex, _seed);
    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(_password, account, _chain, _network, seedHex, _apiService);

      await wallet.init(_walletDatabase);

      _wallets.putIfAbsent(account.uniqueId, () => wallet);
    }

    _isInitialized = true;
  }

  @override
  Future close() async {
    _isInitialized = false;
  }

  @override
  bool isLocked() {
    return walletMutex.isLocked;
  }

  @override
  Future<bool> isAlive() async {
    var isAlive = await _apiService.healthService.isAlive(ChainHelper.chainTypeString(_chain));

    return isAlive;
  }

  @override
  String get walletType => ChainHelper.chainTypeString(_chain);

  @override
  Future<WalletAddress> getNextWalletAddress(WalletAccount walletAccount, AddressType addressType, bool isChangeAddress) async {
    isInitialzed();

    assert(_wallets.containsKey(walletAccount.uniqueId));

    if (_wallets.containsKey(walletAccount.uniqueId)) {
      return await _wallets[walletAccount.uniqueId].nextFreePublicKeyAccount(_walletDatabase, _sharedPrefsUtil, isChangeAddress, addressType);
    }

    throw UnimplementedError();
  }

  Future<List<String>> getPublicKeys() async {
    isInitialzed();
    List<String> keys = [];

    for (var wallet in _wallets.values) {
      keys.addAll(await wallet.getPublicKeys(_walletDatabase));
    }

    return keys;
  }

  Future<String> getPublicKey(bool isChangeAddress, AddressType addressType) async {
    var accounts = await _walletDatabase.getAccounts();
    accounts = accounts.where((element) => element.chain == _chain).toList();
    accounts = accounts.where((element) => element.selected).toList();

    if (accounts.isEmpty) {
      throw new ArgumentError("no active account found...");
    }
    if (accounts.length == 1) {
      final acc = accounts.single;
      final walletAddr = await _wallets[acc.uniqueId].nextFreePublicKeyAccount(_walletDatabase, _sharedPrefsUtil, isChangeAddress, addressType);
      return walletAddr.publicKey;
    }

    for (final wallet in accounts) {
      final walletId = wallet.uniqueId;
      final dbWallet = await _walletDatabase.getAccount(walletId);

      if (dbWallet.selected) {
        if (dbWallet.walletAccountType != WalletAccountType.HdAccount) {
          continue;
        }

        final walletAddr = await _wallets[walletId].nextFreePublicKeyAccount(_walletDatabase, _sharedPrefsUtil, isChangeAddress, addressType);
        return walletAddr.publicKey;
      }
    }
    throw new ArgumentError("");
  }

  @override
  Future<List<WalletAddress>> getPublicKeysFromAccounts(WalletAccount walletAccount) async {
    final addresses = await _walletDatabase.getWalletAddressesById(walletAccount.uniqueId);

    return addresses;
  }

  @override
  Future<WalletAddress> updateAddress(WalletAddress address) {
    isInitialzed();
    return _walletDatabase.addAddress(address);
  }

  @override
  Future<WalletAccount> addAccount(WalletAccount account) {
    isInitialzed();
    return _walletDatabase.addOrUpdateAccount(account);
  }

  Future<bool> hasAccounts() async {
    isInitialzed();
    final acc = await _walletDatabase.getAccounts();
    return acc.isNotEmpty;
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    isInitialzed();
    return _walletDatabase.getAccounts();
  }

  @override
  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> searchAccounts() async {
    isInitialzed();

    var accounts = await getAccounts();
    accounts.sort((a, b) => a.id.compareTo(b.id));

    var accountIdList = accounts.map((e) => e.id).toList();
    var unusedAccounts = await WalletRestore.restore(_chain, _network, _seed, _password, _apiService, existingAccounts: accountIdList);
    unusedAccounts.item1.sort((a, b) => a.id.compareTo(b.id));

    if (unusedAccounts.item1.isEmpty) {
      var lastItem = accounts.last;
      unusedAccounts.item1.add(WalletAccount(Uuid().v4(),
          account: lastItem.account + 1,
          id: lastItem.account + 1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) + (lastItem.account + 2).toString(),
          walletAccountType: WalletAccountType.HdAccount));
    } else {
      var lastItem = unusedAccounts.item1.last;
      unusedAccounts.item1.add(WalletAccount(Uuid().v4(),
          account: lastItem.account + 1,
          id: lastItem.account + 1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) + " " + (lastItem.account + 2).toString(),
          walletAccountType: WalletAccountType.HdAccount));
    }
    return unusedAccounts;
  }

  @override
  Future<String> createAndSend(int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false}) async {
    isInitialzed();

    loadingStream?.add(S.current.wallet_operation_refresh_utxo);
    await ensureUtxo(loadingStream: loadingStream);

    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var txData = await createSendTransaction(amount, token, to, sendMax: sendMax, loadingStream: loadingStream);

      return txData;
    } catch (error) {
      if (error is HttpException) {
        LogHelper.instance.e("Error creating tx..." + error.error.error, error.error);
        throw error.error;
      }
      LogHelper.instance.e("Error creating tx...", error);
      throw error;
    } finally {
      walletMutex.release();
    }
  }

  @protected
  Future<String> createUtxoTransaction(int amount, String to, String changeAddress, {StreamController<String> loadingStream, bool sendMax = false}) async {
    final txb = await createBaseTransaction(amount, to, changeAddress, 0, (txb, inputTxs, nw) => {}, sendMax: sendMax);

    var tx = await createTxAndWait(txb, loadingStream: loadingStream);

    loadingStream?.add(S.current.wallet_operation_send_tx);

    return tx.txId;
  }

  @protected
  Future<ECPair> getPrivateKey(WalletAddress address, WalletAccount walletAccount) async {
    if (walletAccount.walletAccountType == WalletAccountType.HdAccount) {
      final key = seedList;
      final keyPair = HdWalletUtil.getKeyPair(key, address.account, address.isChangeAddress, address.index, address.chain, address.network);
      final pubKey = HdWalletUtil.getPublicKey(key, address.account, address.isChangeAddress, address.index, address.chain, address.network, address.addressType);

      if (pubKey != address.publicKey) {
        throw ArgumentError("Could not regenerate your address, seems your wallet is corrupted");
      }
      return keyPair;
    } else if (walletAccount.walletAccountType == WalletAccountType.PrivateKey) {
      final networkType = HdWalletUtil.getNetworkType(chain, network);
      final privKey = await sl.get<IVault>().getPrivateKey(walletAccount.uniqueId);
      return ECPair.fromWIF(privKey, network: networkType);
    }

    throw new ArgumentError("Something went wrong getting the correct private key!");
  }

  @protected
  Future<Tuple3<String, List<tx.Transaction>, String>> createBaseTransaction(
      int amount, String to, String changeAddress, int additionalFees, Function(TransactionBuilder, List<tx.Transaction>, NetworkType) additional,
      {bool sendMax = false}) async {
    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (amount > tokenBalance?.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);

    final checkAmount = amount + additionalFees;

    var curAmount = 0.0;
    for (final tx in unspentTxs) {
      if (!await walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await walletDatabase.getWalletAddress(tx.address);
      final walletAccount = await walletDatabase.getAccount(address.accountId);

      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        continue;
      }

      if (tx.value <= 0) {
        //ignore auth txs
        continue;
      }
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      var keyPair = await getPrivateKey(address, walletAccount);
      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }

    var fees = await getTxFee(useTxs.length, 2);
    fees += additionalFees;

    if (sendMax) {
      //fees *= -1;
    }

    if (amount == tokenBalance?.balance) {
      amount -= fees;
    }

    if (curAmount < (checkAmount - fees)) {
      throw new ArgumentError("Insufficent funds");
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, to, amount, fees, changeAddress, additional, chain, network);
    return Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, changeAddress);
  }

  Future<TransactionData> createTxAndWait(Tuple3<String, List<tx.Transaction>, String> tx, {StreamController<String> loadingStream}) async {
    final txHex = tx.item1;
    final response = await createTxAndWaitInternal(txHex, loadingStream: loadingStream);

    LogHelper.instance.i("Remove unspent txs " + tx.item2.map((e) => e.uniqueId).join(" - "));
    await _walletDatabase.removeUnspentTransactions(tx.item2);
    for (var out in response.details.outputs) {
      if (await _walletDatabase.isOwnAddress(out.address)) {
        final addressInfo = await walletDatabase.getWalletAddress(out.address);
        final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);
        await _walletDatabase.addUnspentTransaction(out, walletAccount);

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

  Future<TransactionData> createRawTxAndWait(String txHex, {StreamController<String> loadingStream}) async {
    return createTxAndWaitInternal(txHex, loadingStream: loadingStream);
  }

  @protected
  Future<TransactionData> createTxAndWaitInternal(String txHex, {StreamController<String> loadingStream}) async {
    final r = RetryOptions(maxAttempts: 30, maxDelay: Duration(seconds: 5));
    // bool ensureUtxoCalled = false;

    LogHelper.instance.d("commiting tx $txHex");
    try {
      final txId = await r.retry(() async {
        return await _apiService.transactionService.sendRawTransaction(ChainHelper.chainTypeString(_chain), txHex);
      }, retryIf: (e) async {
        if (e is HttpException) {
          if (e.error.error.contains("txn-mempool-conflict")) {
            LogHelper.instance.e("mempool-conflict", e);
            loadingStream?.add(S.current.wallet_operation_mempool_conflict_retry);
            return true;
          }
          return false;
        }
        return false;
      }, onRetry: (e) {
        LogHelper.instance.e("error create tx", e);
      });

      LogHelper.instance.i("commited tx with id " + txId);

      final response = await r.retry(() async {
        return await _apiService.transactionService.getWithTxId(ChainHelper.chainTypeString(_chain), txId);
      }, retryIf: (e) {
        if (e is HttpException || e is ErrorResponse) return true;
        return false;
      }, onRetry: (e) {
        LogHelper.instance.e("error get tx ($txId)", e);
      });

      return response;
    } catch (e) {
      if (e is HttpException) {
        if (e.error.error.contains("txn-mempool-conflict")) {
          throw new MemPoolConflictError(S.current.wallet_operation_mempool_conflict, txHex);
        }
        if (e.error.error.contains("Missing inputs")) {
          throw new MissingInputsError(S.current.wallet_operation_missing_inputs, txHex);
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
    if (inputs == 0 && outputs == 0) return 4000; //default fee is always the same for now
    return (inputs * 250) + (outputs * 50) + 50;
  }

  @protected
  Future ensureUtxo({StreamController<String> loadingStream}) async {
    await walletMutex.acquire();

    try {
      await ensureUtxoUnsafe(loadingStream: loadingStream);
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    } finally {
      walletMutex.release();
    }
  }

  Future ensureUtxoUnsafe({StreamController<String> loadingStream}) async {
    for (final wallet in _wallets.values) {
      await wallet.syncWallet(_walletDatabase, loadingStream: loadingStream);
    }
  }

  @protected
  Future syncTransactions({StreamController<String> loadingStream}) async {
    await walletMutex.acquire();

    try {
      for (final wallet in _wallets.values) {
        await wallet.syncWalletTransactions(_walletDatabase, loadingStream: loadingStream);
      }
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    } finally {
      walletMutex.release();
    }
  }

  @protected
  Future syncAllInternal({StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await syncTransactions(loadingStream: loadingStream);
  }

  Future syncAll({StreamController<String> loadingStream}) async {
    await syncAllInternal(loadingStream: loadingStream);
  }

  @override
  IWalletDatabase getDatabase() {
    return _walletDatabase;
  }
}
