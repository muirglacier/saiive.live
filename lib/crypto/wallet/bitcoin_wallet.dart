import 'dart:async';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'impl/wallet.dart';

class BitcoinWallet extends Wallet {
  BitcoinWallet(bool checkUtxo) : super(ChainType.Bitcoin, checkUtxo);

  @override
  Future<String> createSendTransaction(int amount, String token, String to, String retAddr, {StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = retAddr != null ? retAddr : await this.getPublicKey(true, AddressType.P2SHSegwit);
    return await createUtxoTransaction(amount, to, changeAddress);
  }
}
