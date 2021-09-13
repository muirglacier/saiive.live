import 'dart:async';

import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/services.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:blur/blur.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class AccountsWalletAddressExportPrivateKeyPage extends StatefulWidget {
  final WalletAccount account;
  final WalletAddress address;

  AccountsWalletAddressExportPrivateKeyPage({@required this.account, @required this.address});

  State<StatefulWidget> createState() => _AccountsWalletAddressExportPrivateKeyWidgetState();
}

class _AccountsWalletAddressExportPrivateKeyWidgetState extends State<AccountsWalletAddressExportPrivateKeyPage> {
  bool _showPrivateKey = false;

  String _privateKeyWif = "";
  Timer _timer;

  static const DisplayKeyTimeSeconds = 15;
  int _displayTimerTicker = 0;

  void _init() async {
    final walletService = sl.get<IWalletService>();
    _privateKeyWif = await walletService.getWifPrivateKey(widget.account, widget.address);

    setState(() {});
  }

  void _startTimer() {
    _displayTimerTicker = DisplayKeyTimeSeconds;
    _timer = new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) async {
        setState(() {
          _displayTimerTicker--;
        });

        if (_displayTimerTicker <= 0) {
          setState(() {
            _showPrivateKey = false;
          });
          _timer.cancel();
          _timer = null;

          await ClipboardManager.copyToClipBoard("https://www.saiive.live");
          await Clipboard.setData(new ClipboardData(text: "https://www.saiive.live"));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (_privateKeyWif.isEmpty) {
      return LoadingWidget(text: S.of(context).loading);
    }

    var height = MediaQuery.of(context).size.height * 0.4;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_account_export_private_key),
        ),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Blur(
                  blur: _showPrivateKey ? 0 : 20,
                  colorOpacity: _showPrivateKey ? 0.0 : 0.5,
                  blurColor: Theme.of(context).primaryColor,
                  child: SizedBox(
                      height: height,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20, top: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
                              child: QrImage(
                                data: _privateKeyWif,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.H,
                                foregroundColor: StateContainer.of(context).curTheme.text,
                              )),
                          SelectableText(_privateKeyWif)
                        ]),
                      ))),
              if (!_showPrivateKey)
                ElevatedButton(
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        _startTimer();
                        setState(() {
                          _showPrivateKey = true;
                        });
                      });
                    },
                    child: Text(S.of(context).show)),
              if (_showPrivateKey)
                ElevatedButton(
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () async {
                        await ClipboardManager.copyToClipBoard(_privateKeyWif);
                        ScaffoldMessenger.of(NavigationHelper.navigatorKey.currentContext).showSnackBar(SnackBar(
                          content: Text(S.of(context).receive_address_copied_to_clipboard),
                        ));

                        await Clipboard.setData(new ClipboardData(text: _privateKeyWif));
                      });
                    },
                    child: Text(S.of(context).copy)),
              if (_showPrivateKey) Text(_displayTimerTicker.toString())
            ])));
  }
}
