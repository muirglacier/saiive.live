import 'dart:async';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:tuple/tuple.dart';

import 'address_type.dart';

abstract class IWallet {
  static const int MaxUnusedAccountScan = 3;
  static const int MaxUnusedIndexScan = 2;
  static const int KeysPerQuery = 30;

  String get walletType;

  Future init();
  Future close();
  bool isLocked();
  Future<bool> isAlive();
  Future<bool> hasAccounts();

  Future syncAll({StreamController<String> loadingStream});

  IWalletDatabase getDatabase();

  Future<Transaction> getTransaction(String id);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> addAccount(WalletAccount account);

  void setWorkingAccount(int id);
  Future<String> getPublicKey(AddressType type);
  Future<String> getPublicKeyFromAccount(int account, bool isChangeAddress, AddressType addressType);

  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> searchAccounts();

  Future<String> createSendTransaction(int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false});
  Future<String> createAndSend(int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false});
}
