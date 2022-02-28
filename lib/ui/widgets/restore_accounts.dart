import 'dart:async';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:wakelock/wakelock.dart';

class RestoreAccountsScreen extends StatefulWidget {
  RestoreAccountsScreen();

  @override
  State<StatefulWidget> createState() {
    return _RestoreAccountsScreen();
  }
}

class _RestoreAccountsScreen extends State<RestoreAccountsScreen> {
  var _streamController = new StreamController<String>();

  Future<List<WalletAccount>> searchAccounts() async {
    Wakelock.enable();

    try {
      final network = await sl.get<ISharedPrefsUtil>().getChainNetwork();

      final walletService = sl.get<IWalletService>();

      var result = await walletService.restore(network, loadingStream: _streamController);
      var ret = List<WalletAccount>.empty(growable: true);

      for (final res in result) {
        ret.addAll(res.item1);
      }

      await walletService.init();

      return ret;
    } finally {
      Wakelock.disable();
      _streamController.close();
    }
  }

  @override
  void initState() {
    super.initState();

    sl.get<IHealthService>().checkHealth(context);
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
        return LoadingWidget(text: S.of(context).loading, stream: _streamController.stream);
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
