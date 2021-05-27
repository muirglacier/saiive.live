import 'dart:async';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:tuple/tuple.dart';
import 'impl/wallet.dart';

class BitcoinWallet extends Wallet {
  BitcoinWallet(bool checkUtxo) : super(ChainType.Bitcoin, checkUtxo);

  @override
  Future<Tuple3<String, List<Transaction>, String>> createSendTransaction(int amount, String token, String to) async {
    final changeAddress = await this.getPublicKeyFromAccount(account, true);
    return await createUtxoTransaction(amount, to, changeAddress);
  }
}
