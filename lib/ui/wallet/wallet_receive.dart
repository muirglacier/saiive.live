import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/ui/widgets/wallet_receive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletReceiveScreen extends StatefulWidget {
  final String pubKey;
  final ChainType chain;

  WalletReceiveScreen({@required this.pubKey, @required this.chain});

  _WalletReceiveState createState() => _WalletReceiveState();
}

class _WalletReceiveState extends State<WalletReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            title: Text(S.of(context).wallet_receive),
            actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      ClipboardManager.copyToClipBoard(widget.pubKey).then((result) {
                        ScaffoldMessenger.of(NavigationHelper.navigatorKey.currentContext).showSnackBar(SnackBar(
                          content: Text(S.of(context).receive_address_copied_to_clipboard),
                        ));
                      });
                      Clipboard.setData(new ClipboardData(text: widget.pubKey));
                    },
                    child: Icon(Icons.copy, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  ))
            ]),
        body: WalletReceiveWidget(pubKey: widget.pubKey, chain: widget.chain));
  }
}
