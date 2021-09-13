import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletReceiveWidget extends StatefulWidget {
  final String pubKey;
  final ChainType chain;
  final bool showOnlyQr;

  WalletReceiveWidget({this.pubKey, this.chain, this.showOnlyQr = false});

  _WalletReceiveWidgetState createState() => _WalletReceiveWidgetState();
}

class _WalletReceiveWidgetState extends State<WalletReceiveWidget> {
  openExplorerLink(BuildContext context) async {
    var _chainNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
    var uri = DefiChainConstants.getExplorerAddressUrl(widget.chain, _chainNet, widget.pubKey);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (await canLaunch(uri)) {
        await launch(uri);
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WebViewScreen(uri, "Explorer", canOpenInBrowser: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(children: [
            Container(
                child: Column(children: [
              if (!widget.showOnlyQr) Text(S.of(context).wallet_receive_warning(ChainHelper.chainTypeString(widget.chain)), style: TextStyle(fontWeight: FontWeight.bold)),
              ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
                  child: QrImage(
                    data: widget.pubKey,
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    foregroundColor: StateContainer.of(context).curTheme.text,
                  )),
              SelectableText(widget.pubKey),
              SizedBox(height: 20),
              GestureDetector(
                  onTap: () async {
                    await this.openExplorerLink(context);
                  },
                  child: Text(
                    S.of(context).show_in_explorer,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ))
            ]))
          ]),
        ));
  }
}
