import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:saiive.live/network/model/transaction.dart' as tx;
import "package:collection/collection.dart";
import 'package:uuid/uuid.dart';

import '../chain.dart';

class SembastWalletDatabase extends IWalletDatabase {
  Database _database;

  static const String _addressesStore = "addresses";
  static const String _accountStore = "accounts";
  static const String _accountV2Store = "accountsV2";
  static const String _transactionStore = "transactionsV2";
  static const String _unspentStore = "unspentV2";
  static const String _balanceStore = "balancesV2";

  final StoreRef _accountStoreInstance = intMapStoreFactory.store(_accountStore);
  final StoreRef _accountV2StoreInstance = stringMapStoreFactory.store(_accountV2Store);

  final StoreRef _transactionStoreInstance = StoreRef<String, dynamic>(_transactionStore);
  final StoreRef _unspentStoreInstance = stringMapStoreFactory.store(_unspentStore);

  final StoreRef _balancesStoreInstance = stringMapStoreFactory.store(_balanceStore);

  final StoreRef _addressesStoreInstance = stringMapStoreFactory.store(_addressesStore);

  final _accountStreamController = StreamController<List<WalletAccount>>.broadcast();

  Stream<List<WalletAccount>> get accountStream => _accountStreamController.stream;

  List<String> _activeWalletAddresses = List<String>.empty(growable: true);
  List<String> _activeReadonlyWalletAddresses = List<String>.empty(growable: true);
  List<String> _activeSpentableWalletAddresses = List<String>.empty(growable: true);

  List<String> _removedUnspentTransactions = List<String>.empty(growable: true);

  final String _path;
  final ChainType _chain;
  SembastWalletDatabase(this._path, this._chain);

  Future destroy() async {
    var db = await database;
    await _accountStoreInstance.delete(db);
    await _accountV2StoreInstance.delete(db);
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

  Future open() async {
    await _initAddresses();
  }

  Future _initAddresses() async {
    _activeWalletAddresses = await _getActiveAddresses();
    _activeSpentableWalletAddresses = await _getActiveAddresses(spentable: true);
    _activeReadonlyWalletAddresses = await _getActiveAddresses(spentable: false, all: false);
  }

  Future close() async {
    _database.close();
    _database = null;
  }

  @override
  Future<WalletAddress> addAddress(WalletAddress account) async {
    final db = await database;
    await _addressesStoreInstance.record(account.uniqueId).put(db, account.toJson());

    await _initAddresses();
    return account;
  }

  Future removeAddress(WalletAddress address) async {
    final db = await database;
    await _addressesStoreInstance.record(address.uniqueId).delete(db);
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

  Future<List<WalletAddress>> _getWalletAddressesByAccount(WalletAccount walletAccount) async {
    var dbStore = _addressesStoreInstance;

    var db = await database;
    final finder = Finder(filter: Filter.equals('accountId', walletAccount.uniqueId));

    final accounts = await dbStore.find(db, finder: finder);

    final data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    return data;
  }

  Future<List<WalletAddress>> getWalletAllAddresses(WalletAccount account, {bool onlyActive}) async {
    var dbStore = _addressesStoreInstance;

    var db = await database;

    Finder finder = Finder(filter: Filter.equals('accountId', account.uniqueId));

    final accounts = await dbStore.find(db, finder: finder);

    var data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    if (onlyActive != null && onlyActive) {
      final activeAddresses = await _getActiveAddresses(spentable: true);
      data = data.where((element) => activeAddresses.contains(element.publicKey)).toList();
    }

    return data;
  }

  Future<List<WalletAddress>> getWalletAddressesById(String uniqueId) async {
    var dbStore = _addressesStoreInstance;

    var db = await database;

    var walletAccount = WalletAccount.fromJson(await _accountV2StoreInstance.record(uniqueId).get(db));

    Finder finder;
    if (walletAccount.walletAccountType == WalletAccountType.HdAccount) {
      finder = Finder(filter: Filter.equals('accountId', uniqueId) & (Filter.notNull('createdAt') | Filter.notNull('name')));
    } else {
      finder = Finder(filter: Filter.equals('accountId', uniqueId));
    }

    final accounts = await dbStore.find(db, finder: finder);

    final data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    return data;
  }

  @override
  Future<bool> addressAlreadyUsed(String address) async {
    var dbStore = _transactionStoreInstance;

    var finder = Finder(filter: Filter.equals('address', address));
    var db = await database;
    final accounts = await dbStore.find(db, finder: finder);
    return accounts.isNotEmpty;
  }

  @override
  Future<bool> addressExists(WalletAccount walletAccount, int account, bool isChangeAddress, int index, AddressType addressType) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(
        filter: Filter.equals('account', account) &
            Filter.equals('isChangeAddress', isChangeAddress) &
            Filter.equals('index', index) &
            Filter.equals('addressType', addressType.index) &
            Filter.equals('accountId', walletAccount.uniqueId));

    var accounts = await dbStore.find(await database, finder: finder);

    if (accounts.isEmpty && addressType == AddressType.P2SHSegwit) {
      finder = Finder(
          filter: Filter.equals('account', account) &
              Filter.equals('isChangeAddress', isChangeAddress) &
              Filter.equals('index', index) &
              Filter.equals('accountId', walletAccount.uniqueId));

      accounts = await dbStore.find(await database, finder: finder);
    }

    return accounts.isNotEmpty;
  }

  @override
  Future<WalletAddress> getWalletAddressById(WalletAccount walletAccount, int account, bool isChangeAddress, int index, AddressType addressType) async {
    var dbStore = _addressesStoreInstance;

    var finder = Finder(
        filter: Filter.equals('account', account) &
            Filter.equals('isChangeAddress', isChangeAddress) &
            Filter.equals('index', index) &
            Filter.equals('addressType', addressType.index) &
            Filter.equals('accountId', walletAccount.uniqueId));

    var accounts = await dbStore.find(await database, finder: finder);
    if (accounts.isEmpty && addressType == AddressType.P2SHSegwit) {
      finder = Finder(filter: Filter.equals('account', account) & Filter.equals('isChangeAddress', isChangeAddress) & Filter.equals('index', index));

      accounts = await dbStore.find(await database, finder: finder);
    }
    var data = accounts.map((e) => e == null ? null : WalletAddress.fromJson(e.value))?.toList();

    final activeAddresses = await _getActiveAddresses(spentable: true);
    data = data.where((element) => activeAddresses.contains(element.publicKey)).toList();

    return data.firstOrNull;
  }

  Future<Database> get database async {
    if (_database != null) return _database;

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "wallet_$instanceId.db");

    _database = await databaseFactoryIo.openDatabase(path);
    return _database;
  }

  @override
  Future<WalletAccount> getAccount(String uniqueId) async {
    var db = await database;

    var account = await _accountV2StoreInstance.record(uniqueId).get(db);
    if (account == null) {
      return null;
    }
    var walletAccount = WalletAccount.fromJson(account);

    return walletAccount;
  }

  @override
  Future<List<WalletAccount>> getAccounts() async {
    var db = await database;
    var dbStore = _accountV2StoreInstance;

    var accounts = await dbStore.find(db);
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

  @override
  Future<WalletAccount> addOrUpdateAccount(WalletAccount walletAccount) async {
    final db = await database;

    await _accountV2StoreInstance.record(walletAccount.uniqueId).put(db, walletAccount.toJson());

    await _initAddresses();

    return WalletAccount.fromJson(await _accountV2StoreInstance.record(walletAccount.uniqueId).get(db));
  }

  @override
  Future removeAccount(WalletAccount walletAccount) async {
    final db = await database;

    final walletAddresses = await getWalletAddressesById(walletAccount.uniqueId);
    for (final wa in walletAddresses) {
      await removeAddress(wa);
    }

    await _accountV2StoreInstance.record(walletAccount.uniqueId).delete(db);

    await _initAddresses();
  }

  Future<WalletAccount> addAccount(
      {@required String name, @required int account, @required ChainType chain, @required PathDerivationType derivationPathType, bool isSelected = false}) async {
    final db = await database;

    if (!await _accountV2StoreInstance.record(account).exists(db)) {
      var newAccount = WalletAccount(Uuid().v4(),
          name: name, account: account, id: account, chain: chain, selected: isSelected, walletAccountType: WalletAccountType.HdAccount, derivationPathType: derivationPathType);

      await addOrUpdateAccount(newAccount);

      return newAccount;
    }

    await _initAddresses();

    return WalletAccount.fromJson(await _accountV2StoreInstance.record(account).get(db));
  }

  @override
  Future<List<tx.Transaction>> getAllTransactions() async {
    var dbStore = _transactionStoreInstance;

    final db = await database;
    var finder = Finder(sortOrders: [SortOrder('spentHeight', true)]);
    final transactions = await dbStore.find(db, finder: finder);

    final data = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    return data;
  }

  Future<List<tx.Transaction>> getTransactions(WalletAccount account) async {
    var dbStore = _transactionStoreInstance;

    final db = await database;
    var finder = Finder(filter: Filter.equals('accountId', account.uniqueId), sortOrders: [SortOrder('spentHeight', true)]);
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

  @override
  Future clearTransactions(WalletAccount account) async {
    final txs = await getTransactions(account);
    final txIds = txs.map((e) => e.uniqueId);

    await _transactionStoreInstance.records(txIds).delete(await database);
  }

  Future addTransaction(tx.Transaction transaction, WalletAccount account) async {
    final db = await database;
    transaction.accountId = account.uniqueId;
    final obj = transaction.toJson();

    await _transactionStoreInstance.record(transaction.uniqueId).put(db, obj);
  }

  Future<List<tx.Transaction>> getUnspentTransactionsForWalletAccount(WalletAccount account) async {
    var dbStore = _unspentStoreInstance;

    final db = await database;
    final transactions = await dbStore.find(db, finder: Finder(filter: Filter.equals('spentTxId', null) | Filter.equals('spentTxId', ""), sortOrders: [SortOrder("value", false)]));
    final data = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    return data.where((element) => element.accountId == account.uniqueId).toList();
  }

  @override
  Future<List<tx.Transaction>> getUnspentTransactions({bool spentable = true}) async {
    var dbStore = _unspentStoreInstance;

    final db = await database;
    final transactions = await dbStore.find(db, finder: Finder(filter: Filter.equals('spentTxId', null) | Filter.equals('spentTxId', ""), sortOrders: [SortOrder("value", false)]));
    var activeAddresses = _activeSpentableWalletAddresses;

    if (!spentable) {
      activeAddresses = _activeReadonlyWalletAddresses;
    }

    var data = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();
    data = data.where((element) => activeAddresses.contains(element.address)).toList();

    return data;
  }

  @override
  Future<tx.Transaction> getUnspentTransactionById(String id) async {
    var dbStore = _unspentStoreInstance;

    var finder = Finder(filter: Filter.equals('id', id));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  @override
  Future<tx.Transaction> getUnspentTransactionByTxId(String id) async {
    var dbStore = _unspentStoreInstance;

    var finder = Finder(filter: Filter.equals('mintTxId', id));
    final accounts = await dbStore.find(await database, finder: finder);

    final data = accounts.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();

    if (data.isEmpty) {
      return null;
    }

    return data.first;
  }

  @override
  Future<List<tx.Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount) async {
    var dbStore = _unspentStoreInstance;

    var finder = Finder(filter: Filter.equals('address', pubKey) & Filter.greaterThanOrEquals("value", minAmount));
    final accounts = await dbStore.find(await database, finder: finder);

    var data = accounts.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();
    data = data.where((element) => (element.spentTxId != null || element.spentTxId != '')).toList();
    return data;
  }

  @override
  Future clearUnspentTransactions(WalletAccount account) async {
    if (account == null) {
      return;
    }
    var dbStore = _unspentStoreInstance;

    final db = await database;
    final transactions = await dbStore.find(db, finder: Finder(filter: Filter.equals('accountId', account.uniqueId)));

    var transactionData = transactions.map((e) => e == null ? null : tx.Transaction.fromJson(e.value))?.toList();
    final transactionsIds = transactionData.map((e) => e.uniqueId).toList();

    await _unspentStoreInstance.records(transactionsIds).delete(await database);
  }

  Future removeUnspentTransactions(List<tx.Transaction> txs) async {
    final txIds = txs.map((e) => e.uniqueId).toList();
    await _unspentStoreInstance.records(txIds).delete(await database);

    for (var tx in txs) {
      _removedUnspentTransactions.add(tx.uniqueId);
    }
  }

  @override
  Future addUnspentTransaction(tx.Transaction transaction, WalletAccount account) async {
    final db = await database;

    if (_removedUnspentTransactions.contains(transaction.uniqueId)) {
      return;
    }

    transaction.accountId = account.uniqueId;
    final obj = transaction.toJson();
    await _unspentStoreInstance.record(transaction.uniqueId).put(db, obj);
  }

  Future<bool> transactionExists(String txId) async {
    var dbStore = stringMapStoreFactory.store(_transactionStore);

    return await dbStore.record(txId).exists(await database);
  }

  @override
  Future clearAccountBalances(WalletAccount account) async {
    var accountBalance = await getAccountBalances(account);
    final accountBalanceIds = accountBalance.map((e) => e.key);

    await _balancesStoreInstance.records(accountBalanceIds).delete(await database);
  }

  @override
  Future setAccountBalance(Account balance, WalletAccount walletAccount) async {
    var db = await database;
    balance.accountId = walletAccount.uniqueId;
    await _balancesStoreInstance.record(balance.key).put(db, balance.toJson());
  }

  Future<AccountBalance> getAccountBalance(String token, {List<String> excludeAddresses, bool spentable = true}) async {
    if (token == DeFiConstants.DefiTokenSymbol && _chain == ChainType.DeFiChain) {
      final unspentTx = await getUnspentTransactions(spentable: spentable);
      var amount = 0;

      for (final unspent in unspentTx) {
        amount += unspent.value;
      }

      return new AccountBalance(balance: amount, token: token, chain: this._chain);
    } else if (_chain == ChainType.Bitcoin) {
      final unspentTx = await getUnspentTransactions(spentable: spentable);
      var amount = 0;

      for (final unspent in unspentTx) {
        amount += unspent.value;
      }
      return new AccountBalance(balance: amount, token: ChainHelper.chainTypeString(_chain), chain: this._chain);
    }
    var dbStore = _balancesStoreInstance;
    final db = await database;
    var finder = Finder(filter: Filter.equals('token', token));

    final activeAddresses = spentable ? _activeSpentableWalletAddresses : _activeWalletAddresses;

    final accounts = await dbStore.find(db, finder: finder);

    var data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();
    data = data.where((element) => activeAddresses.contains(element.address)).toList();

    if (excludeAddresses != null && excludeAddresses.isNotEmpty) {
      data.removeWhere((element) => excludeAddresses.contains(element.address));
    }

    final ret = groupBy(data, (e) => e.token);

    Map sumMap = Map<String, int>();

    ret.forEach((k, v) {
      sumMap[k] = v.fold(0, (prev, element) {
        return prev + element.balance;
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

    final activeAddresses = _activeSpentableWalletAddresses;

    var data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();
    data = data.where((element) => activeAddresses.contains(element.address)).toList();

    return data;
  }

  @override
  Future<List<Account>> getAccountBalances(WalletAccount account) async {
    var dbStore = _balancesStoreInstance;

    final accounts = await dbStore.find(await database, finder: Finder(filter: Filter.equals('accountId', account.uniqueId)));

    final data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();

    return data;
  }

  Future<List<String>> _getActiveAddresses({bool spentable = true, bool all = true}) async {
    var activeAccounts = await this.getAccounts();
    activeAccounts = activeAccounts.where((element) => element.selected).toList();

    if (spentable) {
      activeAccounts = activeAccounts.where((element) => element.walletAccountType != WalletAccountType.PublicKey).toList();
    } else if (!all) {
      activeAccounts = activeAccounts.where((element) => element.walletAccountType == WalletAccountType.PublicKey).toList();
    }

    var activeAddresses = List<String>.empty(growable: true);
    for (final acc in activeAccounts) {
      final addresses = await this._getWalletAddressesByAccount(acc);
      activeAddresses.addAll(addresses.map((e) => e.publicKey));
    }
    return activeAddresses;
  }

  Future<List<AccountBalance>> getTotalBalances({bool spentable = true}) async {
    var dbStore = _balancesStoreInstance;

    var activeAddresses = _activeSpentableWalletAddresses;

    if (!spentable) {
      activeAddresses = _activeReadonlyWalletAddresses;
    }
    if (activeAddresses.isEmpty) {
      return List<AccountBalance>.empty(growable: false);
    }

    var finder = Finder(filter: Filter.notEquals('token', DeFiConstants.DefiTokenSymbol));
    final accounts = await dbStore.find(await database, finder: finder);

    var data = accounts.map((e) => e == null ? null : Account.fromJson(e.value))?.toList();
    data = data.where((element) => activeAddresses.contains(element.address)).toList();

    final ret = groupBy(data, (e) => e.token);

    Map sumMap = Map<String, int>();

    ret.forEach((k, v) {
      sumMap[k] = v.fold(0, (prev, element) => prev + element.balance);
    });

    List<AccountBalance> balances = sumMap.entries.map((entry) => AccountBalance(token: entry.key, balance: entry.value, chain: this._chain)).toList();
    balances.add(await getAccountBalance(DeFiConstants.DefiTokenSymbol, spentable: spentable));
    return balances;
  }

  @override
  int getAddressCreationCount() {
    return 20;
  }

  @override
  int getReturnAddressCreationCount() {
    return 20;
  }
}
