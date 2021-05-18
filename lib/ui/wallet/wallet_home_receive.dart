import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/widgets/wallet_receive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletHomeReceiveScreen extends StatefulWidget {
  final String pubKeyDFI;
  final String pubKeyBTC;

  WalletHomeReceiveScreen({this.pubKeyDFI, this.pubKeyBTC});

  _WalletHomeReceiveState createState() => _WalletHomeReceiveState();
}

class _WalletHomeReceiveState extends State<WalletHomeReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'DFI'),
                    Tab(text: 'BTC'),
                  ],
                ),
                title: Text(S.of(context).wallet_receive),
                actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
                actions: [
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          final index = DefaultTabController.of(context).index;
                          final pubKey = index == 0 ? widget.pubKeyDFI : widget.pubKeyBTC;

                          ClipboardManager.copyToClipBoard(pubKey).then((result) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(S.of(context).receive_address_copied_to_clipboard),
                            ));
                          });
                          Clipboard.setData(new ClipboardData(text: pubKey));
                        },
                        child: Icon(
                          Icons.copy,
                          size: 26.0,
                        ),
                      ))
                ]
            ),
            body: TabBarView(
              children: [
                WalletReceiveWidget(pubKey: widget.pubKeyDFI),
                WalletReceiveWidget(pubKey: widget.pubKeyBTC),
              ],
            ),
          );
      })
    );
  }
}
