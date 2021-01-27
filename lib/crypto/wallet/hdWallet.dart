import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/network/model/account.dart';

abstract class IHdWallet {
  Future<List<Account>> syncBalance();

  Future<String> nextFreePublicKey(ChainType chain);
}
