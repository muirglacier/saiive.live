import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionSuccessScreen extends StatelessWidget {
  final ChainType chain;
  final String txId;
  final String text;

  final String additional;
  final String showTxText;

  TransactionSuccessScreen(this.chain, this.txId, this.text, {this.additional, this.showTxText});

  openExplorerLink(BuildContext context) async {
    var _chainNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
    var uri = DefiChainConstants.getExplorerUrl(this.chain, _chainNet, txId);
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
    var showTxText = this.showTxText;
    if (showTxText == null || showTxText.isEmpty) {
      showTxText = S.of(context).wallet_operation_show_tx;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).wallet_operation_success,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1EBCA3),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1EBCA3),
        body: Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_outline_outlined, size: 50, color: Colors.white),
          Text(
            text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (additional != null && additional.isNotEmpty)
            Text(
              additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          if (txId != null && txId.isNotEmpty)
            GestureDetector(
                onTap: () async {
                  await this.openExplorerLink(context);
                },
                child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                      showTxText,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ))),
          GestureDetector(
              onTap: () async {
                await this.openExplorerLink(context);
              },
              child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    txId,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  )))
        ])));
  }
}
