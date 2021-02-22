import 'dart:async';

import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/qr_code_scan.dart';
import 'package:defichainwallet/ui/widgets/loading_overlay.dart';
import 'package:defichainwallet/ui/utils/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class WalletSendScreen extends StatefulWidget {
  final String token;
  final String toAddress;

  WalletSendScreen(this.token, {this.toAddress});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendScreen();
  }
}

class _WalletSendScreen extends State<WalletSendScreen> {
  var _addressController;
  var _amountController = TextEditingController(text: '1');

  Future sendFunds(StreamController<String> stream) async {
    try {
      final amount = double.parse(_amountController.text);
      final totalAmount = (amount * DefiChainConstants.COIN).toInt();

      final tx = await sl.get<DeFiChainWallet>().createAndSend(totalAmount, widget.token, _addressController.text, stream: stream);

      final txId = tx.txId;
      LogHelper.instance.d("sent tx $txId");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(txId),
      ));
    } catch (e) {
      LogHelper.instance.e("Error creating tx", e);
      if (e is ErrorResponse) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error),
        ));
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController(text: widget.toAddress ?? 'tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv');
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).wallet_send)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: S.of(context).wallet_send_address,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        var status = await Permission.camera.status;
                        if (status.isUndetermined) {
                          final permission = await Permission.camera.request();

                          if (!permission.isGranted) {
                            return;
                          }
                        }
                        final address = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => QrCodeScan()));
                        _addressController.text = address;
                      },
                      icon: Icon(Icons.camera_alt),
                    ),
                  )),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(hintText: S.of(context).wallet_send_amount),
              ),
              RaisedButton(
                child: Text(S.of(context).wallet_send),
                color: Theme.of(context).backgroundColor,
                onPressed: () async {
                  sl.get<AuthenticationHelper>().forceAuth(context, () {
                    final streamController = new StreamController<String>();
                    final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                    overlay.during(sendFunds(streamController));
                  });
                },
              )
            ])));
  }
}
