import 'dart:io';

import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';

import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteWalletDatabase extends IWalletDatabase {
  Database _db;

  final String _path;
  SqfliteWalletDatabase(this._path);

  @override
  Future open() async {
    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "wallet_$instanceId.db");

    _db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {});
  }

  @override
  Future close() async {
    await _db.close();
  }

  @override
  Future destroy() async {
    await _db.close();

    final instanceId = await SharedPrefsUtil().getInstanceId();
    final path = join(_path, "wallet_$instanceId.db");

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<WalletAccount> addAccount({String name, int account, ChainType chain, bool isSelected = false}) {
    // TODO: implement addAccount
    throw UnimplementedError();
  }

  @override
  Future addAddress(WalletAddress address) {
    // TODO: implement addAddress
    throw UnimplementedError();
  }

  @override
  Future addTransaction(tx.Transaction transaction) {
    // TODO: implement addTransaction
    throw UnimplementedError();
  }

  @override
  Future addUnspentTransaction(tx.Transaction transaction) {
    // TODO: implement addUnspentTransaction
    throw UnimplementedError();
  }

  @override
  Future<bool> addressExists(int account, bool isChangeAddress, int index) {
    // TODO: implement addressExists
    throw UnimplementedError();
  }

  @override
  Future clearAccountBalances() {
    // TODO: implement clearAccountBalances
    throw UnimplementedError();
  }

  @override
  Future clearTransactions() {
    // TODO: implement clearTransactions
    throw UnimplementedError();
  }

  @override
  Future clearUnspentTransactions() {
    // TODO: implement clearUnspentTransactions
    throw UnimplementedError();
  }

  @override
  Future<AccountBalance> getAccountBalance(String token) {
    // TODO: implement getAccountBalance
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccountBalanceForPubKey(String pubKey, String token) {
    // TODO: implement getAccountBalanceForPubKey
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAccountBalances() {
    // TODO: implement getAccountBalances
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAccountBalancesForToken(String token) {
    // TODO: implement getAccountBalancesForToken
    throw UnimplementedError();
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    // TODO: implement getAccounts
    throw UnimplementedError();
  }

  @override
  int getAddressCreationCount() {
    return 100;
  }

  @override
  Future<int> getNextFreeIndex(int account) {
    // TODO: implement getNextFreeIndex
    throw UnimplementedError();
  }

  @override
  Future<List<AccountBalance>> getTotalBalances() {
    // TODO: implement getTotalBalances
    throw UnimplementedError();
  }

  @override
  Future<tx.Transaction> getTransaction(String id) {
    // TODO: implement getTransaction
    throw UnimplementedError();
  }

  @override
  Future<List<tx.Transaction>> getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  Future<List<tx.Transaction>> getUnspentTransactions() {
    // TODO: implement getUnspentTransactions
    throw UnimplementedError();
  }

  @override
  Future<List<tx.Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount) {
    // TODO: implement getUnspentTransactionsForPubKey
    throw UnimplementedError();
  }

  @override
  Future<WalletAddress> getWalletAddress(String pubKey) {
    // TODO: implement getWalletAddress
    throw UnimplementedError();
  }

  @override
  Future<WalletAddress> getWalletAddressById(int account, bool isChangeAddress, int index) {
    // TODO: implement getWalletAddressById
    throw UnimplementedError();
  }

  @override
  Future<List<WalletAddress>> getWalletAddresses(int account) {
    // TODO: implement getWalletAddresses
    throw UnimplementedError();
  }

  @override
  Future<bool> isOwnAddress(String pubKey) {
    // TODO: implement isOwnAddress
    throw UnimplementedError();
  }

  @override
  Future removeUnspentTransactions(List<tx.Transaction> mintIds) {
    // TODO: implement removeUnspentTransactions
    throw UnimplementedError();
  }

  @override
  Future setAccountBalance(Account balance) {
    // TODO: implement setAccountBalance
    throw UnimplementedError();
  }

  @override
  Future<WalletAccount> updateAccount(WalletAccount account) {
    // TODO: implement updateAccount
    throw UnimplementedError();
  }
}
