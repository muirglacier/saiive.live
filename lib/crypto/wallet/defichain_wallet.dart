import 'package:defichainwallet/crypto/chain.dart';
import 'impl/wallet.dart';

class DeFiChainWallet extends Wallet {
  DeFiChainWallet(bool checkUtxo) : super(ChainType.DeFiChain, checkUtxo);
}
