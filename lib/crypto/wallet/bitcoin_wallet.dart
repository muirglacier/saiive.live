import 'dart:async';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'impl/wallet.dart';

class BitcoinWallet extends Wallet {
  BitcoinWallet(bool checkUtxo) : super(ChainType.Bitcoin, checkUtxo);

  @override
  Future<String> createSendTransaction(int amount, String token, String to,
      {bool waitForConfirmation, String returnAddress, StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = returnAddress ?? await this.getPublicKey(true, AddressType.P2SHSegwit);
    return await createUtxoTransaction(amount, to, changeAddress, version: 2);
  }

  @override
  Future<int> getTxFee(int inputs, int outputs) async {
    if (inputs == 0 && outputs == 0) return 4000; //default fee is always the same for now
    return (inputs * 400) + (outputs * 100) + 200;
  }

  @override
  Future<bool> refreshBefore() {
    return Future.value(true);
  }
}
