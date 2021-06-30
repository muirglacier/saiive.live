import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class AccountsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountsScreen> {
  List<WalletAccount> _walletAccounts = List<WalletAccount>.empty();

  void _init() async {
    var walletService = sl.get<IWalletService>();

    var accounts = await walletService.getAccounts();

    setState(() {
      _walletAccounts = accounts;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  Widget _buildAccountEntry(BuildContext context, WalletAccount account) {
    return Card(
        child: ListTile(
      leading: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(account.name, style: Theme.of(context).textTheme.headline3)]),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Text("Index: ", style: Theme.of(context).textTheme.bodyText1), Text(account.account.toString(), style: Theme.of(context).textTheme.bodyText1)])
      ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(ChainHelper.chainTypeString(account.chain), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))]),
    ));
  }

  Widget _buildAccountPage(BuildContext context) {
    if (_walletAccounts == null || _walletAccounts.isEmpty) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(10),
        child: Scrollbar(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ListView(children: [
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _walletAccounts.length,
                      itemBuilder: (context, index) {
                        return _buildAccountEntry(context, _walletAccounts.elementAt(index));
                      })
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).wallet_accounts)), body: _buildAccountPage(context));
  }
}
