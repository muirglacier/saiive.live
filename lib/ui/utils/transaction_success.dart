import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionSuccessScreen extends StatelessWidget {
  final String txId;
  final String text;

  final String additional;
  final String showTxText;

  TransactionSuccessScreen(this.txId, this.text, {this.additional, this.showTxText});

  openExplorerLink() async {
    var _chainNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
    var url = DefiChainConstants.getExplorerUrl(_chainNet, txId);
    if (await canLaunch(url)) {
      await launch(url);
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
          Icon(Icons.check_circle_outline_outlined, size: 50),
          Text(
            text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (additional != null && additional.isNotEmpty)
            Text(
              additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          GestureDetector(
              onTap: () async {
                await this.openExplorerLink();
              },
              child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    showTxText,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ))),
          GestureDetector(
              onTap: () async {
                await this.openExplorerLink();
              },
              child: Text(
                txId,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ))
        ])));
  }
}
