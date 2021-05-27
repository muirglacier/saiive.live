import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:saiive.live/network/model/transaction.dart' as tx;
import "package:collection/collection.dart";

import '../chain.dart';

class SembastWalletDatabase extends IWalletDatabase {
  Database _database;

  static const int _dbVersion = 2;

  static const String _addressesStore = "addresses";
  static const String _accountStore = "accounts";
  static const String _transactionStore = "transactions";
  static const String _unspentStore = "unspent";
  static const String _balanceStore = "balances";

  final StoreRef _accountStoreInstance = intMapStoreFactory.store(_accountStore);

  final StoreRef _transactionStoreInstance = stringMapStoreFactory.store(_transactionStore);
  final StoreRef _unspentStoreInstance = stringMapStoreFactory.store(_unspentStore);

  final StoreRef _balancesStoreInstance = stringMapStoreFactory.store(_balanceStore);

  final StoreRef _addressesStoreInstance = stringMapStoreFactory.store(_addressesStore);

  final _accountStreamController = StreamController<List<WalletAccount>>.broadcast();
  Stream<List<WalletAccount>> get accountStream => _accountStreamController.stream;

  final String _path;
  final ChainType _chain;
  SembastWalletDatabase(this._path, this._chain);

  Future destroy() async {
    var db = await database;
    await _accountStoreInstance.delete(db);
    await _transactionStoreInstance.delete(db);
    await _unspentStoreInstance.delete(db);
    await _balancesStoreInstance.delete(db);
    await _addressesStoreInstance.delete(db);

    await close();
    _database = null;

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "wallet_$instanceId.db");

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future open() async {}

  Future close() async {
    _database.close();
    _database = null;
  }

  @override
  Future addAddress(WalletAddress account) async {
    final db = await database;
    await _addressesStoreInstance.record(account.uniqueId).put(db, account.toJson());
  }

  @override
  Future<bool> isOwnAddress(String pubKey) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(filter: Filter.equals('publicKey', pubKey));
    final accounts = await dbStore.find(await database, finder: finder);

    return accounts.isNotEmpty;
  }

  @override
  Future<WalletAddress> getWalletAddress(String pubKey) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(filter: Filter.equals('publicKey', pubKey));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    if (data.isNotEmpty) {
      return data.first;
    }

    return null;
  }

  @override
  Future<List<WalletAddress>> getWalletAddresses(int account) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(filter: Filter.equals('account', 0));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    return data;
  }

  @override
  Future<bool> addressExists(int account, bool isChangeAddress, int index) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(filter: Filter.equals('account', account) & Filter.equals('isChangeAddress', isChangeAddress) & Filter.equals('index', index));
    final accounts = await dbStore.find(await database, finder: finder);

    return accounts.isNotEmpty;
  }

  @override
  Future<WalletAddress> getWalletAddressById(int account, bool isChangeAddress, int index) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(filter: Filter.equals('account', account) & Filter.equals('isChangeAddress', isChangeAddress) & Filter.equals('index', index));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    return data.firstOrNull;
  }

  Future<Database> get database async {
    if (_database != null) return _database;

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "wallet_$instanceId.db");

    _database = await databaseFactoryIo.openDatabase(path);
    return _database;
  }

  Future<List<WalletAccount>> getAccounts() async {
    var db = await database;
    var dbStore = _accountStoreInstance;

    final accounts = await dbStore.find(db);

    final data = accounts.map((e) => e == null ? null : WalletAccount.fromJson(e.value))?.toList();

    _accountStreamController.add(data);

    return data;
  }

  Future<int> getNextFreeIndex(int account) async {
    var dbStore = _accountStoreInstance;

    var finder = Finder(filter: Filter.equals('account', account), sortOrders: [SortOrder('index', false)]);

    var records = await dbStore.find(await database, finder: finder);
    if (records.length == 0) {
      return 0;
    }

    return records.first["id"];
  }

  Future<WalletAccount> updateAccount(WalletAccount account) async {
    final db = await database;
    await _accountStoreInstance.record(account.id).put(db, account.toJson());

    return WalletAccount.fromJson(await _accountStoreInstance.record(account.id).get(db));
  }

  Future<WalletAccount> addAccount({@required String name, @required int account, @required ChainType chain, bool isSelected = false}) async {
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

    return WalletAccount.fromJson(await _accountStoreInstance.record(account).get(db));
  }

  Future<List<tx.Transaction>> getTransactions() async {
    var dbStore = _transactionStoreInstance;

    final db = await database;
    var finder = Finder(sortOrders: [SortOrder('spentHeight', true)]);
    final transactions = await dbStore.find(db, finder: finder);

    final data = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    return data;
  }

  @override
  Future<tx.Transaction> getTransaction(String id) async {
    var dbStore = _transactionStoreInstance;

    var finder = Finder(filter: Filter.equals('id', id));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  Future clearTransactions() async {
    final txs = await getTransactions();
    final txIds = txs.map((e) => e.uniqueId);

    await _transactionStoreInstance.records(txIds).delete(await database);
  }

  Future addTransaction(tx.Transaction transaction) async {
    final db = await database;
    final obj = transaction.toJson();
    await _transactionStoreInstance.record(transaction.uniqueId).put(db, obj);
  }

  Future<List<tx.Transaction>> getUnspentTransactions() async {
    var dbStore = _unspentStoreInstance;

    final db = await database;
    final transactions = await dbStore.find(db, finder: Finder(filter: Filter.equals('spentTxId', null) | Filter.equals('spentTxId', ""), sortOrders: [SortOrder("value", false)]));

    final data = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    return data;
  }

  @override
  Future<List<tx.Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount) async {
    var dbStore = _unspentStoreInstance;

    var finder = Finder(filter: Filter.equals('address', pubKey) & Filter.greaterThanOrEquals("value", minAmount));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    return data;
  }

  Future clearUnspentTransactions() async {
    final txs = await getUnspentTransactions();
    final txIds = txs.map((e) => e.uniqueId);

    await _unspentStoreInstance.records(txIds).delete(await database);
  }

  Future removeUnspentTransactions(List<tx.Transaction> txs) async {
    final txIds = txs.map((e) => e.uniqueId);
    await _unspentStoreInstance.records(txIds).delete(await database);
  }

  Future addUnspentTransaction(tx.Transaction transaction) async {
    final db = await database;
    final obj = transaction.toJson();
    await _unspentStoreInstance.record(transaction.uniqueId).put(db, obj);
  }

  Future<bool> transactionExists(String txId) async {
    var dbStore = stringMapStoreFactory.store(_transactionStore);

    return await dbStore.record(txId).exists(await database);
  }

  Future clearAccountBalances() async {
    await _balancesStoreInstance.delete(await database);
  }

  Future setAccountBalance(Account balance) async {
    var db = await database;
    await _balancesStoreInstance.record(balance.key).put(db, balance.toJson());
  }

  Future<AccountBalance> getAccountBalance(String token, {List<String> excludeAddresses}) async {
    if (token == DeFiConstants.DefiTokenSymbol && _chain == ChainType.DeFiChain) {
      final unspentTx = await getUnspentTransactions();
      var amount = 0;

      for (final unspent in unspentTx) {
        amount += unspent.value;
      }

      return new AccountBalance(balance: amount, token: token, chain: this._chain);
    } else if (_chain == ChainType.Bitcoin) {
      final unspentTx = await getUnspentTransactions();
      var amount = 0;

      for (final unspent in unspentTx) {
        amount += unspent.value;
      }
      return new AccountBalance(balance: amount, token: ChainHelper.chainTypeString(_chain), chain: this._chain);
    }
    var dbStore = _balancesStoreInstance;
    final db = await database;
    var finder = Finder(filter: Filter.equals('token', token));
    final accounts = await dbStore.find(db, finder: finder);

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    final ret = groupBy(data, (e) => e.token);

    Map sumMap = Map<String, int>();

    ret.forEach((k, v) {
      sumMap[k] = v.fold(0, (prev, element) {
        if (excludeAddresses != null && !excludeAddresses.contains(element.address)) {
          return prev + element.balance;
        } else if (excludeAddresses == null) {
          return prev + element.balance;
        }
        return 0;
      });
    });

    var sumBalance = sumMap[token];
    return AccountBalance(balance: sumBalance == null ? 0 : sumBalance, token: token, chain: this._chain);
  }

  @override
  Future<Account> getAccountBalanceForPubKey(String pubKey, String token) async {
    var dbStore = _balancesStoreInstance;

    var finder = Finder(filter: Filter.equals('token', token) & Filter.equals('address', pubKey));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  @override
  Future<List<Account>> getAccountBalancesForToken(String token) async {
    var dbStore = _balancesStoreInstance;

    var finder = Finder(filter: Filter.equals('token', token), sortOrders: [SortOrder("balance", false)]);
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    return data;
  }

  Future<List<Account>> getAccountBalances() async {
    var dbStore = _balancesStoreInstance;

    final accounts = await dbStore.find(await database);

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    return data;
  }

  Future<List<AccountBalance>> getTotalBalances() async {
    var dbStore = _balancesStoreInstance;

    var finder = Finder(filter: Filter.notEquals('token', DeFiConstants.DefiTokenSymbol));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    final ret = groupBy(data, (e) => e.token);

    Map sumMap = Map<String, int>();

    ret.forEach((k, v) {
      sumMap[k] = v.fold(0, (prev, element) => prev + element.balance);
    });

    List<AccountBalance> balances = sumMap.entries.map((entry) => AccountBalance(token: entry.key, balance: entry.value, chain: this._chain)).toList();
    balances.add(await getAccountBalance(DeFiConstants.DefiTokenSymbol));
    return balances;
  }

  @override
  int getAddressCreationCount() {
    return 100;
  }
}
