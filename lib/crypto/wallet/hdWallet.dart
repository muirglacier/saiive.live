import 'dart:async';

import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:tuple/tuple.dart';

abstract class IHdWallet {
  Future init(IWalletDatabase walletDatabase);

  Future<List<String>> getPublicKeys(IWalletDatabase walletDatabase);
  Future<String> nextFreePublicKey(IWalletDatabase database, bool isChangeAddress);

  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress);

  Future syncWallet(IWalletDatabase database, {StreamController<String> loadingStream});
  Future syncWalletTransactions(IWalletDatabase database, {StreamController<String> loadingStream});
}
