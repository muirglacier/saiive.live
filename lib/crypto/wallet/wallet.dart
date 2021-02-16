import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/transaction_data.dart';

abstract class IWallet {
  static const int MaxUnusedAccountScan = 3;
  static const int MaxUnusedIndexScan = 2;
  static const int KeysPerQuery = 30;

  Future init();
  Future close();
  
  Future<List<Account>> syncBalance();

  Future<Transaction> getTransaction(String id);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> addAccount(String name, int account);

  void setWorkingAccount(int id);
  Future<String> getPublicKey();
  Future<String> getPublicKeyFromAccount(int account, bool isChangeAddress);

  Future<List<WalletAccount>> searchAccounts();
  
  Future<TransactionData> createAndSend(int amount, String token, String to);

}
