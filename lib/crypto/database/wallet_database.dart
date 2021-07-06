import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:flutter/cupertino.dart';

abstract class IWalletDatabase {
  Future<int> getNextFreeIndex(int account);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> getAccount(String uniqueId);

  @deprecated
  Future<WalletAccount> addAccount({@required String name, @required int account, @required ChainType chain, bool isSelected = false});
  Future<WalletAccount> addOrUpdateAccount(WalletAccount walletAccount);

  Future clearTransactions();
  Future<List<Transaction>> getTransactions();
  Future<Transaction> getTransaction(String id);
  Future addTransaction(Transaction transaction);

  Future clearUnspentTransactions();
  Future clearUnspenTransactionsForAccount(WalletAccount account);
  Future<List<Transaction>> getUnspentTransactions();
  Future removeUnspentTransactions(List<Transaction> mintIds);
  Future<List<Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount);
  Future addUnspentTransaction(Transaction transaction);

  Future clearAccountBalances();
  Future clearAccountBalancesForAccount(WalletAccount account);
  Future setAccountBalance(Account balance);
  Future<List<Account>> getAccountBalances();
  Future<AccountBalance> getAccountBalance(String token, {List<String> excludeAddresses});
  Future<List<Account>> getAccountBalancesForToken(String token);
  Future<List<AccountBalance>> getTotalBalances();
  Future<Account> getAccountBalanceForPubKey(String pubKey, String token);

  Future<WalletAddress> addAddress(WalletAddress address);
  Future<bool> isOwnAddress(String pubKey);
  Future<WalletAddress> getWalletAddress(String pubKey);
  Future<WalletAddress> getWalletAddressById(int account, bool isChangeAddress, int index, AddressType addressType);
  Future<List<WalletAddress>> getWalletAddresses(int account);
  Future<bool> addressExists(int account, bool isChangeAddress, int index, AddressType addressType);
  Future<bool> addressAlreadyUsed(String address);

  Future<List<WalletAddress>> getWalletAddressesById(String uniqueId);

  int getAddressCreationCount();

  Future open();
  Future close();
  Future destroy();
}
