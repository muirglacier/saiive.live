import 'dart:async';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:tuple/tuple.dart';

import 'address_type.dart';

abstract class IHdWallet {
  Future init(IWalletDatabase walletDatabase);

  Future<List<String>> getPublicKeys(IWalletDatabase walletDatabase);
  Future<String> nextFreePublicKey(IWalletDatabase database, SharedPrefsUtil sharedPrefs, bool isChangeAddress, AddressType addressType);

  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress, AddressType addressType);

  Future syncWallet(IWalletDatabase database, {StreamController<String> loadingStream});
  Future syncWalletTransactions(IWalletDatabase database, {StreamController<String> loadingStream});
}
