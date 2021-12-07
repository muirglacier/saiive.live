import 'dart:async';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:tuple/tuple.dart';

import 'address_type.dart';

abstract class IWallet {
  static const int MaxUnusedAccountScan = 1;
  static const int MaxUnusedIndexScan = 2;
  static const int KeysPerQuery = 50;

  static const int MaxUnusedAccountScanBitcoin = 0;
  static const int MaxUnusedIndexScanBitcoin = 1;
  static const int KeysPerQueryBitcoin = 10;

  String get walletType;

  Future init();
  Future close();
  bool isLocked();
  Future<bool> isAlive();
  Future<bool> hasAccounts();

  Future syncAll({StreamController<String> loadingStream});
  Future syncAllTransactions({StreamController<String> loadingStream});

  IWalletDatabase getDatabase();

  Future<Transaction> getTransaction(String id);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> addAccount(WalletAccount account);

  Future<WalletAddress> updateAddress(WalletAddress address);
  Future<WalletAddress> getNextWalletAddress(WalletAccount walletAccount, AddressType addressType, bool isChangeAddress);
  Future<WalletAddress> generateAddress(WalletAccount account, bool isChangeAddress, int index, AddressType addressType);

  Future<List<WalletAddress>> getPublicKeysFromAccounts(WalletAccount walletAccount);

  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> searchAccounts();

  Future<String> createSendTransaction(int amount, String token, String to,
      {bool waitForConfirmation, String returnAddress, StreamController<String> loadingStream, bool sendMax = false});
  Future<String> createAndSend(int amount, String token, String to, {bool waitForConfirmation, String returnAddress, StreamController<String> loadingStream, bool sendMax = false});

  Future<bool> refreshBefore();

  Future<String> signMessage(String address, String message);
  Future<int> getTxFee(int inputs, int outputs);

  Future<bool> validateAddress(WalletAccount account, WalletAddress address);
}
