import 'package:defichainwallet/crypto/chain.dart';

abstract class IHdWallet {
  Future<bool> syncWallet();

  Future<String> nextFreePublicKey(ChainType chain);
}
