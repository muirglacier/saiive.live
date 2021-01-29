
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';

class WalletSendScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletSendScreen();
  }
}

class _WalletSendScreen extends State<WalletSendScreen> {
  void initWallet() async {
    var wallet = sl.get<DeFiChainWallet>();
    var pubKey = await wallet.getPublicKey();
  }

  @override
  void initState() {
    super.initState();

    initWallet();
  }

  @override
  Widget build(Object context) {
    return Scaffold(body: Text("send"));
  }
}
