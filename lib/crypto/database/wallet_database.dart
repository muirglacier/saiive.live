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
  Future<WalletAccount> addAccount(
      {@required String name, @required int account, @required ChainType chain, @required PathDerivationType derivationPathType, bool isSelected = false});
  Future<WalletAccount> addOrUpdateAccount(WalletAccount walletAccount);
  Future removeAccount(WalletAccount walletAccount);
  Future removeAccountAddress(WalletAddress walletAddress);

  Future clearTransactions(WalletAccount account);

  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactions(WalletAccount account);
  Future<Transaction> getTransaction(String id);
  Future addTransaction(Transaction transaction, WalletAccount account);

  Future clearUnspentTransactions(WalletAccount account);
  Future<List<Transaction>> getUnspentTransactions({bool spentable = true});
  Future<Transaction> getUnspentTransactionById(String txId);
  Future<Transaction> getUnspentTransactionByTxId(String txId);
  Future removeUnspentTransactions(List<Transaction> mintIds);
  Future<List<Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount);
  Future addUnspentTransaction(Transaction transaction, WalletAccount account);

  Future clearAccountBalances(WalletAccount account);
  Future setAccountBalance(Account balance, WalletAccount account);
  Future<List<Account>> getAccountBalances(WalletAccount account);
  Future<AccountBalance> getAccountBalance(String token, {List<String> excludeAddresses, bool spentable = true});
  Future<List<Account>> getAccountBalancesForToken(String token);
  Future<List<AccountBalance>> getTotalBalances({bool spentable = true});
  Future<Account> getAccountBalanceForPubKey(String pubKey, String token);
  Future<List<Account>> getAccountBalancesForPubKey(String pubKey);

  Future<WalletAddress> addAddress(WalletAddress address);
  Future<bool> isOwnAddress(String pubKey);
  Future<WalletAddress> getWalletAddress(String pubKey);
  Future<WalletAddress> getWalletAddressById(WalletAccount walletAccount, int account, bool isChangeAddress, int index, AddressType addressType);
  Future<List<WalletAddress>> getWalletAllAddresses(WalletAccount account, {bool onlyActive});
  Future<bool> addressExists(WalletAccount walletAccount, int account, bool isChangeAddress, int index, AddressType addressType);
  Future<bool> addressAlreadyUsed(String address);

  Future<List<WalletAddress>> getWalletAddressesById(String uniqueId);

  Future open();
  Future close();
  Future destroy();
}
