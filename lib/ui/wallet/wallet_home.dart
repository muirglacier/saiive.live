import 'dart:async';

import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/events/events.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/settings/settings.dart';
import 'package:defichainwallet/ui/wallet/wallet_receive.dart';
import 'package:defichainwallet/ui/wallet/wallet_token.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class WalletHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletHomeScreenScreen();
  }
}

class _WalletHomeScreenScreen extends State<WalletHomeScreen> {
  StreamSubscription<WalletInitDoneEvent> _walletInitDoneSubscription;
  StreamSubscription<WalletSyncDoneEvent> _walletSyncDoneSubscription;

  String _welcomeText = "";
  String _syncText = " ";

  List<AccountBalance> _accountBalance;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  _refresh() async {
    EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

    _refreshController.refreshCompleted();
    final syncText = S.of(context).home_welcome_account_syncing;
    setState(() {
      _syncText = syncText;
    });
  }

  _initWallet() async {
    EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
    if (_walletInitDoneSubscription == null) {
      _walletInitDoneSubscription = EventTaxiImpl.singleton()
          .registerTo<WalletInitDoneEvent>()
          .listen((event) async {
        final accounts = await StateContainer.of(context).wallet.getAccounts();
        if (accounts.length == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/intro_accounts_restore", (route) => false);
        }

        var accountBalance = await sl.get<IWalletDatabase>().getTotalBalances();

        setState(() {
          _accountBalance = accountBalance;
        });

        _initSyncText();
      });
    }

    EventTaxiImpl.singleton().fire(WalletInitStartEvent());
  }

  _syncEvents() {
    if (_walletSyncDoneSubscription == null) {
      _walletSyncDoneSubscription = EventTaxiImpl.singleton()
          .registerTo<WalletSyncDoneEvent>()
          .listen((event) async {
        final accounts = await StateContainer.of(context).wallet.getAccounts();
        if (accounts.length == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/intro_accounts_restore", (route) => false);
        }

        var accountBalance = await sl.get<IWalletDatabase>().getTotalBalances();

        setState(() {
          _syncText = sprintf(S.of(context).home_welcome_account_synced,
              [accounts.length.toString()]);
          _accountBalance = accountBalance;
        });
      });
    }
    _refreshController.loadComplete();
  }

  _initSyncText() {
    var date = DateTime.now();

    var welcomeText = S.of(context).home_welcome_good_day;
    if (date.hour > 11 && date.hour <= 18) {
      welcomeText = S.of(context).home_welcome_good_day;
    } else if (date.hour >= 18) {
      welcomeText = S.of(context).home_welcome_good_evening;
    }

    final syncText = S.of(context).home_welcome_account_syncing;
    setState(() {
      _welcomeText = welcomeText;
      _syncText = syncText;
    });
  }

  @override
  void initState() {
    super.initState();

    _syncEvents();
    _initWallet();
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_walletInitDoneSubscription != null) {
      _walletInitDoneSubscription.cancel();
      _walletInitDoneSubscription = null;
    }
    if (_walletSyncDoneSubscription != null) {
      _walletSyncDoneSubscription.cancel();
      _walletSyncDoneSubscription = null;
    }
  }

  Widget _buildAccountEntry(AccountBalance balance) {
    return Card(
        child: ListTile(
      leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.account_balance_wallet)]),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(balance.token,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Text(balance.token, style: TextStyle(fontSize: 12))
          ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(balance.balance.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ]),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => WalletTokenScreen(balance.token)));
      },
    ));
  }

  buildWalletScreen(BuildContext context) {
    if (_accountBalance == null) {
      return;
    }

    if (_accountBalance.isEmpty) {
      return Padding(
          padding: EdgeInsets.all(30),
          child: Row(
              children: [
                Text(S.of(context).wallet_empty)
              ]
          )

      );
    }
    return Padding(
        padding: EdgeInsets.all(30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  child: Center(
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemExtent: 100.0,
                          itemCount: _accountBalance.length,
                          itemBuilder: (context, index) {
                            final account = _accountBalance.elementAt(index);
                            return _buildAccountEntry(account);
                          })))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_welcomeText, style: TextStyle(fontSize: 15)),
              Text(_syncText, style: TextStyle(fontSize: 12))
            ],
          ),
          actionsIconTheme: Theme.of(context).iconTheme,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    var wallet = sl.get<DeFiChainWallet>();
                    var pubKey = await wallet.getPublicKey();

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => WalletReceiveScreen(pubKey: pubKey)));
                  },
                  child: Icon(
                    Icons.arrow_downward,
                    size: 26.0,
                  ),
                )
            ),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SettingsScreen()));
                  },
                  child: Icon(
                    Icons.settings,
                    size: 26.0,
                  ),
                ))
          ],
        ),
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _refresh,
            onLoading: _initWallet,
            child: buildWalletScreen(context)));
  }
}
