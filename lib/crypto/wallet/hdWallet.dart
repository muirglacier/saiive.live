import 'dart:async';

import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:tuple/tuple.dart';

abstract class IHdWallet {
  Future init(IWalletDatabase walletDatabase);

  Future<List<String>> getPublicKeys(IWalletDatabase walletDatabase);
  Future<String> nextFreePublicKey(IWalletDatabase database, SharedPrefsUtil sharedPrefs, bool isChangeAddress);

  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress);

  Future syncWallet(IWalletDatabase database, {StreamController<String> loadingStream});
  Future syncWalletTransactions(IWalletDatabase database, {StreamController<String> loadingStream});
}
