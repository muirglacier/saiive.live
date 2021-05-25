import 'package:saiive.live/crypto/chain.dart';
import 'impl/wallet.dart';

class BitcoinWallet extends Wallet {
  BitcoinWallet(bool checkUtxo) : super(ChainType.Bitcoin, checkUtxo);
}
