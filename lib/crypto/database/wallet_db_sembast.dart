import 'dart:async';
import 'dart:io';

import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import "package:collection/collection.dart";

import '../chain.dart';

class SembastWalletDatabase extends IWalletDatabase {
  Database _database;

  static const int _dbVersion = 1;

  static const String _accountStore = "accounts";
  static const String _transactionStore = "transactions";
  static const String _balanceStore = "balances";

  final StoreRef _accountStoreInstance =
      intMapStoreFactory.store(_accountStore);

  final StoreRef _transactionStoreInstance =
      stringMapStoreFactory.store(_transactionStore);

  final StoreRef _balancesStoreInstance =
      stringMapStoreFactory.store(_balanceStore);

  final _accountStreamController =
      StreamController<List<WalletAccount>>.broadcast();
  Stream<List<WalletAccount>> get accountStream =>
      _accountStreamController.stream;

  final String _path;
  SembastWalletDatabase(this._path);

  Future destroy() async {
    _database = null;

    final file = File(_path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future open() async {}

  Future close() async {
    _database.close();
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database;
    final file = File(_path);

    if (await file.exists()) {
      debugPrint("Use existing database...");
    } else {
      debugPrint("Create new database...");
    }
    _database = await databaseFactoryIo.openDatabase(_path);
    return _database;
  }

  Future<List<WalletAccount>> getAccounts() async {
    var db = await database;
    var dbStore = _accountStoreInstance;

    final accounts = await dbStore.find(db);

    final data = accounts
        .map((e) => e == null ? null : WalletAccount.fromJson(e.value))
        ?.toList();

    _accountStreamController.add(data);

    return data;
  }

  Future<int> getNextFreeIndex(int account) async {
    var dbStore = _accountStoreInstance;

    var finder = Finder(
        filter: Filter.equals('account', account),
        sortOrders: [SortOrder('index', false)]);

    var records = await dbStore.find(await database, finder: finder);
    if (records.length == 0) {
      return 0;
    }
    return records.first["index"] + 1;
  }

  Future<WalletAccount> updateAccount(WalletAccount account) async {
    final db = await database;
    await _accountStoreInstance
        .record(account.id)
        .put(db, account.toJson());

    return WalletAccount.fromJson(
        await _accountStoreInstance.record(account.id).get(db));
  }

  Future<WalletAccount> addAccount(
      {@required String name,
      @required int account,
      @required ChainType chain,
      bool isSelected = false}) async {
    final db = await database;

    if (!await _accountStoreInstance.record(account).exists(db)) {
      var newAccount = WalletAccount();
      newAccount.name = name;
      newAccount.account = account;
      newAccount.id = account;
      newAccount.chain = chain;
      newAccount.selected = isSelected;

      await _accountStoreInstance.record(account).put(db, newAccount.toJson());

      return newAccount;
    }

    return WalletAccount.fromJson(
        await _accountStoreInstance.record(account).get(db));
  }

  Future<List<tx.Transaction>> getTransactions() async {
    var dbStore = _transactionStoreInstance;

    final transactions = await dbStore.find(await database);

    final data = transactions
        .map((e) => e == null ? null : tx.Transaction.fromJson(e.value))
        ?.toList();

    return data;
  }

  Future addTransaction(
      tx.Transaction transaction, int account, int index) async {
    await _getStoreAndAdd(_transactionStore, transaction.toJson(),
        transaction.id, account, index);
  }

  Future _getStoreAndAdd(String store, Map<String, dynamic> item, String key,
      int account, int index) async {
    item.putIfAbsent("index", () => index);
    item.putIfAbsent("account", () => account);

    final dbStore = stringMapStoreFactory.store(store);
    await dbStore.record(key).put(await database, item);
  }

  Future<bool> transactionExists(String txId) async {
    var dbStore = stringMapStoreFactory.store(_transactionStore);

    return await dbStore.record(txId).exists(await database);
  }

  Future setAccountBalance(Account balance) async {
    await _balancesStoreInstance
        .record(balance.key)
        .put(await database, balance.toJson());
  }

  Future<List<Account>> getAccountBalance() async {
    var dbStore = _balancesStoreInstance;

    final accounts = await dbStore.find(await database);

    final data = accounts
        .map((e) => e == null ? null : Account.fromJson(e.value))
        ?.toList();

    return data;
  }

  Future<Map<String, double>> getTotalBalances() async {
    var dbStore = _balancesStoreInstance;

    final accounts = await dbStore.find(await database);

    final data = accounts
        .map((e) => e == null ? null : Account.fromJson(e.value))
        ?.toList();

    final ret = groupBy(data, (e) => e.token);

    Map sumMap = Map<String, double>();

    ret.forEach((k, v) {
      sumMap[k] = v.fold(0, (prev, element) => prev + element.balance);
    });

    return sumMap;
  }
}
