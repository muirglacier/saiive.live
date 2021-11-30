import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/addressbook/addressbook_screen.dart';
import 'package:saiive.live/ui/utils/qr_code_scan.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:wakelock/wakelock.dart';

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

  var _sendAmount = 0;

  String _toAddress;

  Future sendFunds(StreamController<String> stream) async {
    try {
      Wakelock.enable();

      var tokenAmount = await BalanceHelper().getAccountBalance(widget.token, widget.chainType);

      sl.get<AppCenterWrapper>().trackEvent("sendToken", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text});

      final tx = await sl.get<IWalletService>().createAndSend(widget.chainType, _sendAmount, widget.token, _addressController.text, _toAddress,
          waitForConfirmaton: true, loadingStream: stream, sendMax: _sendAmount == tokenAmount.balance);

      final txId = tx;
      LogHelper.instance.d("sent tx $txId");
      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      sl
          .get<AppCenterWrapper>()
          .trackEvent("sendTokenSuccess", <String, String>{"coin": widget.token, "to": _addressController.text, "amount": _amountController.text, "txId": txId});

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(widget.chainType, txId, S.of(context).wallet_operation_success),
      ));

      Navigator.of(context).pop();
    } catch (e) {
      sl.get<AppCenterWrapper>().trackEvent("sendTokenFailure", <String, String>{"coin": widget.token, 'amount': _amountController.text, 'error': e.toString()});
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, widget.chainType, error: e),
      ));
    } finally {
      Wakelock.disable();
    }
  }

  handleSetMax() async {
    var tokenAmount = await BalanceHelper().getAccountBalance(widget.token, widget.chainType);
    _amountController.text = (tokenAmount.balance / DefiChainConstants.COIN).toString();

    _sendAmount = tokenAmount.balance;
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

    _amountController.addListener(() {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final totalAmount = (amount * DefiChainConstants.COIN).toInt();
      _sendAmount = totalAmount;
    });
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
                            keyboardType: TextInputType.text,
                            decoration: (Platform.isMacOS || Platform.isWindows)
                                ? InputDecoration(hintText: S.of(context).wallet_send_address)
                                : InputDecoration(
                                    hintText: S.of(context).wallet_send_address,
                                    suffixIcon: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (Platform.isAndroid || Platform.isIOS)
                                            IconButton(
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
                                              icon: Icon(Icons.camera_alt, color: StateContainer.of(context).curTheme.primary),
                                            ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            onPressed: () async {
                                              AddressBookEntry usedAddress;
                                              await Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (BuildContext context) => AddressBookScreen(
                                                      selectOnlyMode: true,
                                                      chainFilter: widget.chainType,
                                                      onAddressSelected: (a) {
                                                        usedAddress = a;
                                                      })));

                                              if (usedAddress != null) {
                                                setState(() {
                                                  _addressController.text = usedAddress.publicKey;
                                                });
                                              }
                                            },
                                            icon: Icon(Icons.import_contacts, color: StateContainer.of(context).curTheme.primary),
                                          ),
                                        ])))))
              ]),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(hintText: S.of(context).wallet_send_amount),
                    ))),
                SizedBox(height: 20),
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
              WalletReturnAddressWidget(
                onChanged: (v) {
                  setState(() {
                    _toAddress = v;
                  });
                },
              ),
              SizedBox(
                width: 20,
                height: 20,
              ),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    child: Text(S.of(context).wallet_send),
                    style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        final streamController = new StreamController<String>();
                        final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                        overlay.during(sendFunds(streamController));
                      });
                    },
                  ))
            ])));
  }
}
