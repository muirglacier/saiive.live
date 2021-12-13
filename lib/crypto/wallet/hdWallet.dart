import 'dart:async';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:tuple/tuple.dart';

import 'address_type.dart';

abstract class IHdWallet {
  WalletAccount get walletAccount;

  Future init(IWalletDatabase walletDatabase, ISharedPrefsUtil sharedPrefs);

  Future<List<WalletAddress>> getPublicKeys(IWalletDatabase walletDatabase, {bool onlyActive});
  @deprecated
  Future<String> nextFreePublicKey(IWalletDatabase database, ISharedPrefsUtil sharedPrefs, bool isChangeAddress, AddressType addressType);
  Future<WalletAddress> nextFreePublicKeyAccount(IWalletDatabase database, ISharedPrefsUtil sharedPrefs, bool isChangeAddress, AddressType addressType);

  Future<WalletAddress> generateAddress(IWalletDatabase database, WalletAccount account, bool isChangeAddress, int index, AddressType addressType, {bool previewOnly = false});

  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress, AddressType addressType);

  Future syncWallet(IWalletDatabase database, {StreamController<String> loadingStream});
  Future syncWalletTransactions(IWalletDatabase database, {StreamController<String> loadingStream});
}
