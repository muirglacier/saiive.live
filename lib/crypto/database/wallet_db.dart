import 'dart:async';
import 'dart:io';

import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/vault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import "package:collection/collection.dart";

import '../chain.dart';

class WalletDatabase {
  WalletDatabase._();

  static final WalletDatabase instance = WalletDatabase._();

  static Database _database;

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

  static Future destory() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final dbName = await sl.get<Vault>().getSeedHash();
    final path = join(documentsDirectory.path, "db", dbName + "wallet.db");

    _database = null;

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database;

    final dbName = await sl.get<Vault>().getSeedHash();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "db", dbName + "_wallet.db");

    final file = File(path);

    if (await file.exists()) {
      debugPrint("Use existing database...");
    } else {
      debugPrint("Create new database...");
    }

    _database = await databaseFactoryIo.openDatabase(path, version: _dbVersion);
    return _database;
  }

  Future<List<WalletAccount>> getAccounts() async {
    var dbStore = _accountStoreInstance;
    final db = await database;

    final accounts = await dbStore.find(db);

    final data = accounts
        .map((e) => e == null ? null : WalletAccount.fromJson(e.value))
        ?.toList();

    _accountStreamController.add(data);

    return data;
  }

  Future<int> getNextFreeIndex(int account) async {
    var dbStore = _accountStoreInstance;
    final db = await database;

    var finder = Finder(
        filter: Filter.equals('account', account),
        sortOrders: [SortOrder('index', false)]);

    var records = await dbStore.find(db, finder: finder);
    if (records.length == 0) {
      return 0;
    }
    return records.first["index"] + 1;
  }

  Future<WalletAccount> updateAccount(WalletAccount account) async {
    final db = await database;

    await _accountStoreInstance.record(account.id).put(db, account.toJson());

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
    final db = await database;

    final transactions = await dbStore.find(db);

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
    final db = await database;
    await dbStore.record(key).put(db, item);
  }

  Future<bool> transactionExists(String txId) async {
    var dbStore = stringMapStoreFactory.store(_transactionStore);
    final db = await database;

    return await dbStore.record(txId).exists(db);
  }

  Future setAccountBalance(Account balance) async {
    final db = await database;
    await _balancesStoreInstance.record(balance.key).put(db, balance.toJson());
  }

  Future<List<Account>> getAccountBalance() async {
    var dbStore = _balancesStoreInstance;
    final db = await database;

    final accounts = await dbStore.find(db);

    final data = accounts
        .map((e) => e == null ? null : Account.fromJson(e.value))
        ?.toList();

    return data;
  }

  Future<Map<String, double>> getTotalBalances() async {
    var dbStore = _balancesStoreInstance;
    final db = await database;

    final accounts = await dbStore.find(db);

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
