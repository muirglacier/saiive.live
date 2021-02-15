import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:tuple/tuple.dart';

abstract class IHdWallet {
  Future<List<Account>> syncBalance();

  Future<List<String>> getPublicKeys();
  Future<String> nextFreePublicKey(IWalletDatabase database, bool isChangeAddress);
  
  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress);
  Future<List<Transaction>> syncUnspentTransactions();
}
