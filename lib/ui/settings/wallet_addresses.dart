import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletAddressesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletAddressesScreen();
  }
}

class _WalletAddressesScreen extends State<WalletAddressesScreen> {
  List<WalletAddress> _walletAddresses = [];
  List<String> _walletAddressesString = [];

  loadAddresses() async {
    final walletDb = sl.get<IWalletDatabase>();
    _walletAddresses = await walletDb.getWalletAddresses(0);

    for (final address in _walletAddresses) {
      var path = HdWalletUtil.derivePath(address.account, address.isChangeAddress, address.index);

      _walletAddressesString.add(address.publicKey + " @ " + path);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadAddresses();
  }

  _buildAddressEntry(BuildContext context, String address) {
    return Row(children: [Text(address)]);
  }

  _buildWalletAddressList(BuildContext context) {
    if (_walletAddresses == null || _walletAddresses.length == 0) {
      return Padding(padding: EdgeInsets.all(30), child: Row(children: [Text("No address found...")]));
    }

    return Padding(
        padding: EdgeInsets.all(0),
        child: SingleChildScrollView(
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _walletAddressesString.length,
                itemBuilder: (context, index) {
                  final account = _walletAddressesString.elementAt(index);
                  return _buildAddressEntry(context, account);
                })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      await ClipboardManager.copyToClipBoard(_walletAddressesString?.join("\r\n"));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.of(context).receive_address_copied_to_clipboard),
                      ));

                      Clipboard.setData(new ClipboardData(text: _walletAddressesString?.join("\r\n")));
                    },
                    child: Icon(
                      Icons.copy,
                      size: 26.0,
                    ),
                  ))
            ],
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            title: Text("Addresses")),
        body: _buildWalletAddressList(context));
  }
}
