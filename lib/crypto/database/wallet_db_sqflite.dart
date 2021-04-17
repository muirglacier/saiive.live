// import 'package:defichainwallet/crypto/chain.dart';
// import 'package:defichainwallet/crypto/database/wallet_database.dart';
// import 'package:defichainwallet/network/model/transaction.dart';
// import 'package:defichainwallet/network/model/account_balance.dart';
// import 'package:defichainwallet/network/model/account.dart';
// import 'package:defichainwallet/crypto/model/wallet_address.dart';
// import 'package:defichainwallet/crypto/model/wallet_account.dart';
// import 'package:sqflite/sqflite.dart';

// class SqfliteWalletDatabase extends IWalletDatabase {
//   final String path;
//   SqfliteWalletDatabase(this.path);

//   @override
//   Future open() {
//     // TODO: implement open
//     throw UnimplementedError();
//   }

//   @override
//   Future close() {
//     // TODO: implement close
//     throw UnimplementedError();
//   }

//   @override
//   Future destroy() {
//     // TODO: implement destroy
//     throw UnimplementedError();
//   }

//   @override
//   Future<WalletAccount> addAccount({String name, int account, ChainType chain, bool isSelected = false}) {
//     // TODO: implement addAccount
//     throw UnimplementedError();
//   }

//   @override
//   Future addAddress(WalletAddress address) {
//     // TODO: implement addAddress
//     throw UnimplementedError();
//   }

//   @override
//   Future addTransaction(Transaction transaction) {
//     // TODO: implement addTransaction
//     throw UnimplementedError();
//   }

//   @override
//   Future addUnspentTransaction(Transaction transaction) {
//     // TODO: implement addUnspentTransaction
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> addressExists(int account, bool isChangeAddress, int index) {
//     // TODO: implement addressExists
//     throw UnimplementedError();
//   }

//   @override
//   Future clearAccountBalances() {
//     // TODO: implement clearAccountBalances
//     throw UnimplementedError();
//   }

//   @override
//   Future clearTransactions() {
//     // TODO: implement clearTransactions
//     throw UnimplementedError();
//   }

//   @override
//   Future clearUnspentTransactions() {
//     // TODO: implement clearUnspentTransactions
//     throw UnimplementedError();
//   }

//   @override
//   Future<AccountBalance> getAccountBalance(String token) {
//     // TODO: implement getAccountBalance
//     throw UnimplementedError();
//   }

//   @override
//   Future<Account> getAccountBalanceForPubKey(String pubKey, String token) {
//     // TODO: implement getAccountBalanceForPubKey
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Account>> getAccountBalances() {
//     // TODO: implement getAccountBalances
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Account>> getAccountBalancesForToken(String token) {
//     // TODO: implement getAccountBalancesForToken
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<WalletAccount>> getAccounts() {
//     // TODO: implement getAccounts
//     throw UnimplementedError();
//   }

//   @override
//   int getAddressCreationCount() {
//     // TODO: implement getAddressCreationCount
//     throw UnimplementedError();
//   }

//   @override
//   Future<int> getNextFreeIndex(int account) {
//     // TODO: implement getNextFreeIndex
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<AccountBalance>> getTotalBalances() {
//     // TODO: implement getTotalBalances
//     throw UnimplementedError();
//   }

//   @override
//   Future<Transaction> getTransaction(String id) {
//     // TODO: implement getTransaction
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Transaction>> getTransactions() {
//     // TODO: implement getTransactions
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Transaction>> getUnspentTransactions() {
//     // TODO: implement getUnspentTransactions
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount) {
//     // TODO: implement getUnspentTransactionsForPubKey
//     throw UnimplementedError();
//   }

//   @override
//   Future<WalletAddress> getWalletAddress(String pubKey) {
//     // TODO: implement getWalletAddress
//     throw UnimplementedError();
//   }

//   @override
//   Future<WalletAddress> getWalletAddressById(int account, bool isChangeAddress, int index) {
//     // TODO: implement getWalletAddressById
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<WalletAddress>> getWalletAddresses(int account) {
//     // TODO: implement getWalletAddresses
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> isOwnAddress(String pubKey) {
//     // TODO: implement isOwnAddress
//     throw UnimplementedError();
//   }

//   @override
//   Future removeUnspentTransactions(List<Transaction> mintIds) {
//     // TODO: implement removeUnspentTransactions
//     throw UnimplementedError();
//   }

//   @override
//   Future setAccountBalance(Account balance) {
//     // TODO: implement setAccountBalance
//     throw UnimplementedError();
//   }

//   @override
//   Future<WalletAccount> updateAccount(WalletAccount account) {
//     // TODO: implement updateAccount
//     throw UnimplementedError();
//   }
// }
