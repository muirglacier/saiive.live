import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_add_screen.dart';
import 'package:saiive.live/ui/accounts/accounts_select_action_screen.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

import 'accounts_import_screen.dart';

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
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AccountsSelectActionScreen((chainType) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(settings: RouteSettings(name: "/accountsAddScreen"), builder: (BuildContext context) => AccountsAddScreen(chainType)));
                            })));
                  },
                  child: Icon(Icons.add, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                )),
            Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AccountsSelectActionScreen((chainType) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(settings: RouteSettings(name: "/accountsImportScreen"), builder: (BuildContext context) => AccountsImportScreen(chainType)));
                            })));
                  },
                  child: Icon(Icons.upload, size: 30.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                ))
          ],
        ),
        body: _buildAccountPage(context));
  }
}
