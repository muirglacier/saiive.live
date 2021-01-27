import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart';

abstract class IWallet {
  static const int MaxUnusedAccountScan = 3;
  static const int MaxUnusedIndexScan = 2;
  static const int KeysPerQuery = 20;

  Future init();
  Future<List<Account>> syncBalance();

  Future<Transaction> getTransaction(String id);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> addAccount(String name, int account);

  void setWorkingAccount(int id);
  Future<String> getPublicKey();
  Future<String> getPublicKeyFromAccount(int account);

  Future<List<WalletAccount>> searchAccounts();
}
