import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class WalletAddressesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletAddressesScreen();
  }
}

class _WalletAddressesScreen extends State<WalletAddressesScreen> {
  List<String> _walletAddresses = [];

  loadAddresses() async {
    final walletService = sl.get<IWalletService>();

    final accounts = await walletService.getAccounts();

    _walletAddresses.add("");
    _walletAddresses.add("DeFiChain");
    _walletAddresses.add("");
    _walletAddresses.add("");

    for (var acc in accounts.where((element) => element.chain == ChainType.DeFiChain)) {
      var walletAddresses = await walletService.getAllPublicKeysFromAccount(acc);

      for (var element in walletAddresses) {
        var path = HdWalletUtil.derivePath(element.account, element.isChangeAddress, element.index, acc.derivationPathType);
        _walletAddresses.add("${element.publicKey} ($path)");
      }
    }

    _walletAddresses.add("");
    _walletAddresses.add("");
    _walletAddresses.add("Bitcoin");
    _walletAddresses.add("");
    for (var acc in accounts.where((element) => element.chain == ChainType.Bitcoin)) {
      var walletAddresses = await walletService.getAllPublicKeysFromAccount(acc);

      for (var element in walletAddresses) {
        var path = HdWalletUtil.derivePath(element.account, element.isChangeAddress, element.index, acc.derivationPathType);
        _walletAddresses.add("${element.publicKey} ($path)");
      }
    }
    _walletAddresses.add("");

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadAddresses();
  }

  _buildAddressEntry(BuildContext context, String address) {
    return Row(children: [SelectableText(address)]);
  }

  _buildWalletAddressList(BuildContext context) {
    if (_walletAddresses == null || _walletAddresses.length == 0) {
      return Padding(padding: EdgeInsets.all(30), child: Row(children: [LoadingWidget(text: S.of(context).loading)]));
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
    return Scaffold(
        appBar: AppBar(
            actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      await ClipboardManager.copyToClipBoard(_walletAddresses?.join("\r\n"));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S.of(context).receive_address_copied_to_clipboard),
                      ));

                      Clipboard.setData(new ClipboardData(text: _walletAddresses?.join("\r\n")));
                    },
                    child: Icon(Icons.copy, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  ))
            ],
            toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
            title: Text("Addresses")),
        body: Center(child: _buildWalletAddressList(context)));
  }
}
