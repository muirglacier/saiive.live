import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/qr_code_scan.dart';
import 'package:flutter/material.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

class WalletSendScreen extends StatefulWidget {
  final String token;
  WalletSendScreen(this.token);

  @override
  State<StatefulWidget> createState() {
    return _WalletSendScreen();
  }
}

class _WalletSendScreen extends State<WalletSendScreen> {
  var _addressController =
      TextEditingController(text: 'tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv');
  var _amountController = TextEditingController(text: '5');

  Future sendFunds() async {
    final amount = double.parse(_amountController.text);
    final totalAmount = (amount * 100000000).toInt();
    final tx = await sl.get<DeFiChainWallet>().createSendTransaction(
        totalAmount, widget.token, _addressController.text);

    final apiService = sl.get<ApiService>();

    final txId =
        await apiService.transactionService.sendRawTransaction("DFI", tx);

    debugPrint("Commited: " + txId);

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
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
                        final address = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    QrCodeScan()));
                        _addressController.text = address;
                      },
                      icon: Icon(Icons.camera_alt),
                    ),
                  )),
              TextField(
                controller: _amountController,
                decoration:
                    InputDecoration(hintText: S.of(context).wallet_send_amount),
              ),
              RaisedButton(
                child: Text(S.of(context).wallet_send),
                color: Theme.of(context).backgroundColor,
                onPressed: () async {
                  await sendFunds();
                },
              )
            ])));
  }
}
