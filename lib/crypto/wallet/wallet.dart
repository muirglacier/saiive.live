import 'dart:async';

import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/transaction_data.dart';
import 'package:tuple/tuple.dart';

abstract class IWallet {
  static const int MaxUnusedAccountScan = 3;
  static const int MaxUnusedIndexScan = 2;
  static const int KeysPerQuery = 30;

  String get walletType;

  Future init();
  Future close();
  bool isLocked();
  Future<bool> isAlive();

  Future syncAll({StreamController<String> loadingStream});

  IWalletDatabase getDatabase();

  Future<Transaction> getTransaction(String id);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> addAccount(String name, int account);

  void setWorkingAccount(int id);
  Future<String> getPublicKey();
  Future<String> getPublicKeyFromAccount(int account, bool isChangeAddress);

  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> searchAccounts();

  Future<TransactionData> createAndSend(int amount, String token, String to, {StreamController<String> loadingStream});
  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream});

  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream});
}
