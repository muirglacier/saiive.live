import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/vault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletReceiveScreen extends StatefulWidget {
  String pubKey;

  WalletReceiveScreen({this.pubKey});

  _WalletReceiveState createState() => _WalletReceiveState();
}

class _WalletReceiveState extends State<WalletReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).wallet_receive)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                    child: Column(children: [
                  QrImage(
                    data: widget.pubKey,
                    size: MediaQuery.of(context).size.width - 60,
                  ),
                  Text(widget.pubKey)
                ]))
              ],
            )));
  }
}
