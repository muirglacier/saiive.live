import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:flutter/foundation.dart';

import 'package:mutex/mutex.dart';

class Wallet extends IWallet {
  Map<int, IHdWallet> _wallets = Map<int, IHdWallet>();

  final Mutex _mutex = Mutex();

  int _account;
  final ChainType _chain;
  final ChainNet _network;

  final String _password;
  final String _seed;
  final ApiService _apiService;
  final IWalletDatabase _walletDatabase;

  Wallet(this._password, this._account, this._chain, this._network, this._seed,
      this._apiService, this._walletDatabase);

  @override
  Future init() async {
    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(
          _password, account, _chain, _network, _seed, _apiService, _walletDatabase);

      _wallets.putIfAbsent(account.account, () => wallet);
    }
  }

  @override
  void setWorkingAccount(int account) {
    _account = account;
  }

  @override
  Future<String> getPublicKey() async {
    return getPublicKeyFromAccount(_account);
  }

  @override
  Future<String> getPublicKeyFromAccount(int account) async {
    if (_wallets.containsKey(account)) {
      return await _wallets[account].nextFreePublicKey(_chain);
    }
    throw UnimplementedError();
  }

  @override
  Future syncWallet() async {
    if (_mutex.isLocked) {
      return;
    }
    var startDate = DateTime.now();

    try {
      _mutex.acquire();

      for (final wallet in _wallets.values) {
        await wallet.syncWallet();
      }

      // var futures = _wallets.values.map((e) => e.syncWallet());
      // await Future.wait(futures);

      _mutex.release();
      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      debugPrint(e.toString());
      _mutex.release();
    }
  }

  @override
  Future<WalletAccount> addAccount(String name, int account) {
    return _walletDatabase
        .addAccount(name: name, account: account, chain: _chain);
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    return _walletDatabase.getAccounts();
  }

  @override
  Future<List<WalletAccount>> searchAccounts() async {
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
  Future<Transaction> getTransaction(String id) {
    // TODO: implement getTransaction
    throw UnimplementedError();
  }
}
