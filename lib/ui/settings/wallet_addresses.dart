import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletAddressesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletAddressesScreen();
  }
}

class _WalletAddressesScreen extends State<WalletAddressesScreen> {
  List<WalletAddress> _walletAddresses = [];

  loadAddresses() async {
    final walletDb = sl.get<IWalletDatabase>();
    _walletAddresses = await walletDb.getWalletAddresses(0);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadAddresses();
  }

  _buildAddressEntry(BuildContext context, WalletAddress address) {
    var path = HdWalletUtil.derivePath(address.account, address.isChangeAddress, address.index);

    return Row(children: [Text(address.publicKey), Text(" @ "), Text(path)]);
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
                itemCount: _walletAddresses.length,
                itemBuilder: (context, index) {
                  final account = _walletAddresses.elementAt(index);
                  return _buildAddressEntry(context, account);
                })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text("Addresses")), body: _buildWalletAddressList(context));
  }
}
