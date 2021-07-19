import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/events/events.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/block.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/accounts_screen.dart';
import 'package:saiive.live/ui/settings/settings.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/wallet/wallet_token.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WalletHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletHomeScreenScreen();
  }
}

class _WalletHomeScreenScreen extends State<WalletHomeScreen> with TickerProviderStateMixin {
  StreamSubscription<WalletInitDoneEvent> _walletInitDoneSubscription;
  StreamSubscription<WalletSyncDoneEvent> _walletSyncDoneSubscription;
  StreamSubscription<BlockTipUpdatedEvent> _blockTipUpdatedEvent;
  StreamSubscription<WalletSyncStartEvent> _walletSyncStartEvent;

  AnimationController _controller;

  Block _lastSyncBlockTip;

  String _welcomeText = "";
  String _syncText = " ";
  bool _isSyncing = false;

  List<AccountBalance> _accountBalance;
  List<AccountBalance> _readonlyAccountBalance;

  _refresh() async {
    EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

    sl.get<IHealthService>().checkHealth(context);
  }

  _initWallet() async {
    if (_walletSyncStartEvent == null) {
      _walletSyncStartEvent = EventTaxiImpl.singleton().registerTo<WalletSyncStartEvent>().listen((event) async {
        final syncText = S.of(context).home_welcome_account_syncing;

        final balanceHelper = new BalanceHelper();
        var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);
        var readonlyAccountBalance = await balanceHelper.getDisplayAccountBalance(spentable: false);

        _controller.forward();
        setState(() {
          _accountBalance = accountBalance;
          _readonlyAccountBalance = readonlyAccountBalance;
          _syncText = syncText;

          _isSyncing = true;
        });
      });
    }

    if (_walletInitDoneSubscription == null) {
      _walletInitDoneSubscription = EventTaxiImpl.singleton().registerTo<WalletInitDoneEvent>().listen((event) async {
        final balanceHelper = new BalanceHelper();
        var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);
        var readonlyAccountBalance = await balanceHelper.getDisplayAccountBalance(spentable: false);

        setState(() {
          _accountBalance = accountBalance;
          _readonlyAccountBalance = readonlyAccountBalance;
        });

        _initSyncText();
      });
    }

    EventTaxiImpl.singleton().fire(WalletInitStartEvent());
  }

  _syncEvents() {
    final wallet = sl.get<IWalletService>();

    if (_walletSyncDoneSubscription == null) {
      _walletSyncDoneSubscription = EventTaxiImpl.singleton().registerTo<WalletSyncDoneEvent>().listen((event) async {
        final accounts = await wallet.getAccounts();
        if (accounts.length == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil("/intro_accounts_restore", (route) => false);
        }
        final balanceHelper = new BalanceHelper();
        var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);
        var readonlyAccountBalance = await balanceHelper.getDisplayAccountBalance(spentable: false);

        setState(() {
          _controller.stop();
          _controller.reset();

          _isSyncing = false;

          _syncText = S.of(context).home_welcome_account_synced;
          _accountBalance = accountBalance;
          _readonlyAccountBalance = readonlyAccountBalance;
        });
      });
    }

    if (_blockTipUpdatedEvent == null) {
      _blockTipUpdatedEvent = EventTaxiImpl.singleton().registerTo<BlockTipUpdatedEvent>().listen((event) async {
        setState(() {
          _lastSyncBlockTip = event.block;
        });
      });
    }
  }

  _initLastSyncedBlock() async {
    var hasLastBlock = await sl.get<SharedPrefsUtil>().hasLastSyncedBlock();

    if (hasLastBlock) {
      var block = await sl.get<SharedPrefsUtil>().getLastSyncedBlock();

      setState(() {
        _lastSyncBlockTip = block;
      });
    }
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.isCompleted && _isSyncing) {
        _controller.repeat();
      }
    });

    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openWalletHome", <String, String>{});

    _syncEvents();
    _initWallet();
    _initLastSyncedBlock();
    _refresh();

    _welcomeText = "Welcome";
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

    if (_blockTipUpdatedEvent != null) {
      _blockTipUpdatedEvent.cancel();
      _blockTipUpdatedEvent = null;
    }

    if (_walletSyncStartEvent != null) {
      _walletSyncStartEvent.cancel();
      _walletSyncStartEvent = null;
    }
  }

  Widget _buildAccountEntry(AccountBalance balance) {
    if (balance is MixedAccountBalance) {
      return Card(
          child: ListTile(
        leading: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [TokenIcon(balance.token)]),
        title: Column(children: [
          Row(children: [
            Text(
              balance.token,
              style: Theme.of(context).textTheme.headline3,
            ),
            Expanded(
                child: AutoSizeText(
              FundFormatter.format(balance.balanceDisplay),
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.right,
              maxLines: 1,
            )),
          ]),
          Container(height: 10),
          Row(children: [
            Text(
              'UTXO',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Expanded(
                child: AutoSizeText(
              FundFormatter.format(balance.utxoBalanceDisplay),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
              maxLines: 1,
            )),
          ]),
          Row(children: [
            Text(
              'Token',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Expanded(
                child: AutoSizeText(
              FundFormatter.format(balance.tokenBalanceDisplay),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
              maxLines: 1,
            )),
          ]),
        ]),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletTokenScreen(balance.token, balance.chain, balance.tokenDisplay, balance)));
        },
      ));
    }

    return Card(
        child: ListTile(
      leading: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [TokenIcon(balance.token)]),
      title: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            balance.tokenDisplay,
            style: Theme.of(context).textTheme.headline3,
          ),
          if (balance.additionalDisplay != null)
            Chip(
                label: Text(
                  balance.additionalDisplay,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                backgroundColor: Theme.of(context).primaryColor)
        ]),
        Expanded(
            child: AutoSizeText(
          FundFormatter.format(balance.balanceDisplay),
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.right,
          maxLines: 1,
        )),
      ]),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletTokenScreen(balance.token, balance.chain, balance.tokenDisplay, balance)));
      },
    ));
  }

  buildMultiWalletScreen(BuildContext context) {
    if (_accountBalance == null || _readonlyAccountBalance == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    var map = {S.of(context).wallet_accounts_spentable: _accountBalance};

    if (_readonlyAccountBalance.isNotEmpty) {
      map.putIfAbsent(S.of(context).wallet_accounts_readonly, () => _readonlyAccountBalance);
    }

    return buildGroupedList(context, map);
  }

  buildGroupedList(BuildContext context, Map<String, List<AccountBalance>> items) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: RefreshIndicator(
            onRefresh: () async {
              return await _refresh();
            },
            child: GroupListView(
              sectionsCount: items.keys.toList().length,
              countOfItemInSection: (int section) {
                return items.values.toList()[section].length;
              },
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, IndexPath index) {
                return _buildAccountEntry(items.values.toList()[index.section][index.index]);
              },
              groupHeaderBuilder: (BuildContext context, int section) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Text(
                    items.keys.toList()[section],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              },
              dragStartBehavior: DragStartBehavior.down,
              separatorBuilder: (context, index) => SizedBox(height: 5),
              sectionSeparatorBuilder: (context, section) => SizedBox(height: 5),
            )));
  }

  buildWalletScreen(BuildContext context, bool useReadonlyData) {
    var balances = _accountBalance;

    if (useReadonlyData) {
      balances = _readonlyAccountBalance;
    }
    return Padding(
        padding: EdgeInsets.all(30),
        child: CustomScrollView(physics: BouncingScrollPhysics(), scrollDirection: Axis.vertical, slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final account = balances.elementAt(index);
                return _buildAccountEntry(account);
              },
              childCount: balances.length,
            ),
          )
        ]));

    // SliverList(
    //     delegate: SliverChildBuilderDelegate(
    //           (BuildContext context, int index) {
    //         final account = _accountBalance.elementAt(index);
    //         return _buildAccountEntry(account);
    //       },
    //       childCount: _accountBalance.length,
    //     ),
    // child: ListView.builder(
    //     physics: BouncingScrollPhysics(),
    //     scrollDirection: Axis.vertical,
    //     shrinkWrap: true,
    //     itemExtent: 100.0,
    //     itemCount: _accountBalance.length,
    //     itemBuilder: (context, index) {
    //       final account = _accountBalance.elementAt(index);
    //       return _buildAccountEntry(account);
    //     })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Row(children: [
            if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      var key = StateContainer.of(context).scaffoldKey;
                      key.currentState.openDrawer();
                    },
                    child: Icon(Icons.view_headline, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                  )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_welcomeText, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(_syncText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (_lastSyncBlockTip != null)
                  Row(children: [
                    Text(S.of(context).home_welcome_account_block_height, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    Text(_lastSyncBlockTip.height.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ]),
              ],
            )
          ]),
          actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 0),
                child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                      onPressed: !_isSyncing
                          ? () async {
                              await _refresh();
                            }
                          : null,
                    ))),
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsScreen()));
                  },
                  child: Icon(Icons.arrow_downward, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                )),
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsScreen()));
                  },
                  child: Icon(Icons.settings, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                ))
          ],
        ),
        body: buildMultiWalletScreen(context));
  }
}
