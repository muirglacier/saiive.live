import 'dart:async';

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/response/error_response.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/utils/qr_code_scan.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class WalletSendScreen extends StatefulWidget {
  final String token;
  final String toAddress;
  final ChainType chainType;

  WalletSendScreen(this.token, this.chainType, {this.toAddress});

  @override
  State<StatefulWidget> createState() {
    return _WalletSendScreen();
  }
}

class _WalletSendScreen extends State<WalletSendScreen> {
  var _addressController;
  var _amountController = TextEditingController(text: '1');
  EnvironmentType _currentEnvironment;

  Future sendFunds(StreamController<String> stream) async {
    try {
      final amount = double.parse(_amountController.text);
      final totalAmount = (amount * DefiChainConstants.COIN).toInt();

      sl.get<AppCenterWrapper>().trackEvent("sendToken", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text});

      final tx = await sl.get<IWalletService>().createAndSend(widget.chainType, totalAmount, widget.token, _addressController.text, loadingStream: stream);

      final txId = tx.txId;
      LogHelper.instance.d("sent tx $txId");

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(txId),
      ));

      sl
          .get<AppCenterWrapper>()
          .trackEvent("sendTokenSuccess", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text, "txId": txId});
    } on TransactionError catch (e) {
      final errorMsg = e.error;
      LogHelper.instance.e("Tx Error...($errorMsg)");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg),
      ));
      sl.get<AppCenterWrapper>().trackEvent("sendTokenFailureHandled", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.error});
    } catch (e) {
      LogHelper.instance.e("Error creating tx", e);
      if (e is ErrorResponse) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error),
        ));

        sl.get<AppCenterWrapper>().trackEvent("sendTokenFailureHandled", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.error});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));

        sl.get<AppCenterWrapper>().trackEvent("sendTokenFailure", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.toString()});
      }
    }
  }

  Future utxoToAccount(StreamController<String> stream) async {
    try {
      final amount = double.parse(_amountController.text);
      final totalAmount = (amount * DefiChainConstants.COIN).toInt();

      sl.get<AppCenterWrapper>().trackEvent("sendToken", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text});

      final tx = await sl.get<DeFiChainWallet>().prepareAccount(totalAmount, loadingStream: stream);

      final txId = tx.txId;
      LogHelper.instance.d("sent tx $txId");

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(txId),
      ));

      sl
          .get<AppCenterWrapper>()
          .trackEvent("sendTokenSuccess", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text, "txId": txId});
    } catch (e) {
      LogHelper.instance.e("Error creating tx", e);
      if (e is ErrorResponse) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error),
        ));

        sl.get<AppCenterWrapper>().trackEvent("sendTokenFailureHandled", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.error});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));

        sl.get<AppCenterWrapper>().trackEvent("sendTokenFailure", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.toString()});
      }
    }
  }

  handleSetMax() async {
    var tokenAmount = await BalanceHelper().getAccountBalance(widget.token, widget.chainType);
    _amountController.text = (tokenAmount.balance / DefiChainConstants.COIN).toString();
  }

  @override
  void initState() {
    super.initState();

    sl.get<IHealthService>().checkHealth(context);
    sl.get<AppCenterWrapper>().trackEvent("openWalletSend", <String, String>{"coin": widget.token});

    _currentEnvironment = EnvHelper.getEnvironment();

    var toAddress = widget.toAddress;

    if (_currentEnvironment == EnvironmentType.Development) {
      toAddress = widget.toAddress ?? 'tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv';
    }

    _addressController = TextEditingController(text: toAddress);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).wallet_send)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              hintText: S.of(context).wallet_send_address,
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  var status = await Permission.camera.status;
                                  if (!status.isGranted) {
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
                            ))))
              ]),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(hintText: S.of(context).wallet_send_amount),
                    ))),
                SizedBox(width: 20),
                ButtonTheme(
                    height: 30,
                    minWidth: 40,
                    child: ElevatedButton(
                        child: Text(S.of(context).liquidity_add_max),
                        onPressed: () {
                          handleSetMax();
                        }))
              ]),
              SizedBox(height: 20),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    child: Text(S.of(context).wallet_send, style: TextStyle(color: StateContainer.of(context).curTheme.text)),
                    style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        final streamController = new StreamController<String>();
                        final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                        overlay.during(sendFunds(streamController));
                      });
                    },
                  )),
              if (_currentEnvironment == EnvironmentType.Development && widget.chainType == ChainType.DeFiChain)
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          child: Text("UTXO_TO_ACCOUNT", style: TextStyle(color: StateContainer.of(context).curTheme.text)),
                          style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                          onPressed: () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () {
                              final streamController = new StreamController<String>();
                              final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                              overlay.during(utxoToAccount(streamController));
                            });
                          },
                        )))
            ])));
  }
}
