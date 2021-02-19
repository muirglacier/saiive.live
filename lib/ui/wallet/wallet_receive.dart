import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletReceiveScreen extends StatefulWidget {
  final String pubKey;

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
                    foregroundColor: StateContainer.of(context).curTheme.text,
                    size: MediaQuery.of(context).size.width - 60,
                  ),
                  Text(widget.pubKey)
                ]))
              ],
            )));
  }
}
