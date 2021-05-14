import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/services/wallet_service.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

import 'package:defichainwallet/util/sharedprefsutil.dart';

class RestoreAccountsScreen extends StatefulWidget {
  RestoreAccountsScreen();

  @override
  State<StatefulWidget> createState() {
    return _RestoreAccountsScreen();
  }
}

class _RestoreAccountsScreen extends State<RestoreAccountsScreen> {
  Future<List<WalletAccount>> searchAccounts() async {
    final network = await sl.get<SharedPrefsUtil>().getChainNetwork();

    final walletService = sl.get<IWalletService>();

    var result = await walletService.restore(network);
    var ret = List<WalletAccount>.empty(growable: true);

    for (final res in result) {
      ret.addAll(res.item1);
    }

    return ret;
  }

  Widget _buildAccountEntry(WalletAccount account) {
    return Center(
        child: Row(children: <Widget>[
      Icon(
        Icons.arrow_right,
        size: 19.0,
        color: StateContainer.of(context).curTheme.primary,
      ),
      Padding(padding: EdgeInsets.only(left: 5), child: Text(account.name, style: TextStyle(color: StateContainer.of(context).curTheme.primary, fontSize: 15)))
    ]));
  }

  Widget _buildAccountListWrap(BuildContext context, List<WalletAccount> accounts) {
    return Column(children: <Widget>[
      Text(
        S.of(context).wallet_restore_accountsFound,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
      Expanded(
          flex: 1,
          child: Column(children: [
            Expanded(flex: 1, child: Padding(padding: EdgeInsets.only(top: 10), child: _buildAccountListEntry(accounts))),
            ElevatedButton(
              child: Text(S.of(context).next),
              onPressed: () async {
                Navigator.of(context).pushNamedAndRemoveUntil("/home", (_) => false);
              },
            ),
            Text(
              S.of(context).wallet_restore_accountsAdded,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            )
          ]))
    ]);
  }

  Widget _buildAccountListEntry(List<WalletAccount> accounts) {
    if (accounts.isEmpty) {
      return Center(child: Text(S.of(context).wallet_restore_noAccountFound, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)));
    } else {
      return SingleChildScrollView(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _buildAccountEntry(account);
              }));
    }
  }

  Widget _buildRestoreRunner(BuildContext context) {
    return FutureBuilder<List<WalletAccount>>(
      future: searchAccounts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<WalletAccount> data = snapshot.data;
          return _buildAccountListWrap(context, data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return LoadingWidget(text: S.of(context).loading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).welcome_wallet_restore)),
        body: Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    S.of(context).wallet_restore_loading,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ))),
          Expanded(flex: 1, child: Padding(padding: EdgeInsets.all(20), child: _buildRestoreRunner(context)))
        ])));
  }
}
