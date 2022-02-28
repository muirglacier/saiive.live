import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/channel.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/events/events.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/block.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/price.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/prices_background.dart';
import 'package:saiive.live/ui/accounts/accounts_screen.dart';
import 'package:saiive.live/ui/settings/settings.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/wallet/wallet_buy.dart';
import 'package:saiive.live/ui/wallet/wallet_token.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/buttons.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({Key key}) : super(key: key);

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

  StreamSubscription<PricesLoadedEvent> _pricesLoadedEvent;
  StreamSubscription<PriceLoadingStarted> _pricesLoadingEvent;

  bool _pricesLoading = true;
  List<Price> _prices;
  double _tetherPrice = 1.0;
  CurrencyEnum _currency = CurrencyEnum.USD;

  AnimationController _controller;

  Block _lastSyncBlockTip;

  String _welcomeText = "";
  String _syncText = " ";
  bool _isSyncing = false;

  List<AccountBalance> _accountBalance;
  List<AccountBalance> _readonlyAccountBalance;
  Timer _timer;

  _refresh() async {
    _controller.forward();
    EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

    sl.get<IHealthService>().checkHealth(context);

    _prices = sl<PricesBackgroundService>().get();
    var tetherPrice = sl<PricesBackgroundService>().tetherPrice();

    if (tetherPrice != null) _tetherPrice = tetherPrice.fiat;
    _currency = await sl<ISharedPrefsUtil>().getCurrency();

    setState(() {
      _isSyncing = true;
      _pricesLoading = false;
    });
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

    if (_pricesLoadingEvent == null) {
      _pricesLoadingEvent = EventTaxiImpl.singleton().registerTo<PriceLoadingStarted>().listen((event) async {
        setState(() {
          _pricesLoading = true;
        });
      });
    }

    if (_pricesLoadedEvent == null) {
      _pricesLoadedEvent = EventTaxiImpl.singleton().registerTo<PricesLoadedEvent>().listen((event) async {
        setState(() {
          _pricesLoading = false;
          _prices = event.prices;
          _tetherPrice = event.tetherPrice.fiat;
          _currency = event.currency;
        });
      });
    }

    EventTaxiImpl.singleton().fire(WalletInitStartEvent());
  }

  _updateBalances() async {
    final balanceHelper = new BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);
    var readonlyAccountBalance = await balanceHelper.getDisplayAccountBalance(spentable: false);

    setState(() {
      _accountBalance = accountBalance;
      _readonlyAccountBalance = readonlyAccountBalance;
    });
  }

  _syncEvents() {
    if (_walletSyncDoneSubscription == null) {
      _walletSyncDoneSubscription = EventTaxiImpl.singleton().registerTo<WalletSyncDoneEvent>().listen((event) async {
        print("---------------------- 11..wallet sync done event is called....");
        await _updateBalances();

        setState(() {
          _controller.stop();
          _controller.reset();

          _isSyncing = false;

          _syncText = S.of(context).home_welcome_account_synced;
        });

        var pubKeyListDFI = await sl.get<DeFiChainWallet>().getPublicKeys(onlyActive: true);
        var pubKeyListBTC = await sl.get<BitcoinWallet>().getPublicKeys(onlyActive: true);

        sl.get<ChannelConnection>().sendPublicKeysDFI(pubKeyListDFI);
        sl.get<ChannelConnection>().sendPublicKeysBTC(pubKeyListBTC);

        print("---------------------- wallet sync done event is called....");
      });
    }

    if (_blockTipUpdatedEvent == null) {
      _blockTipUpdatedEvent = EventTaxiImpl.singleton().registerTo<BlockTipUpdatedEvent>().listen((event) async {
        setState(() {
          _lastSyncBlockTip = event.block;
          _isSyncing = false;
        });
      });
    }
  }

  _initLastSyncedBlock() async {
    var hasLastBlock = await sl.get<ISharedPrefsUtil>().hasLastSyncedBlock();

    if (hasLastBlock) {
      var block = await sl.get<ISharedPrefsUtil>().getLastSyncedBlock();

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

  void _startTimer() {
    _timer = new Timer.periodic(
      Duration(minutes: 5),
      (Timer timer) async {
        await _refresh();
      },
    );
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
    _updateBalances();
    _syncEvents();
    _initWallet();
    _initLastSyncedBlock();
    _refresh();

    _startTimer();
    _welcomeText = "Welcome";
  }

  @override
  void deactivate() {
    super.deactivate();
    _timer.cancel();

    _controller.dispose();

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

    if (_pricesLoadedEvent != null) {
      _pricesLoadedEvent.cancel();
      _pricesLoadedEvent = null;
    }

    if (_pricesLoadingEvent != null) {
      _pricesLoadingEvent.cancel();
      _pricesLoadingEvent = null;
    }
  }

  Widget _buildAccountEntry(AccountBalance balance) {
    var price = _prices != null ? _prices.firstWhere((element) => element.token == balance.token, orElse: () => null) : null;
    var priceUsd = price != null ? price.aggregated.amount : null;
    var finalPrice = 1.0;

    if (priceUsd != null) {
      finalPrice = priceUsd * _tetherPrice;
    } else {
      finalPrice = null;
    }
    if (balance.token.toLowerCase() == 'dusd') {
      priceUsd = 1;
      finalPrice = 1;
    }

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
          if (priceUsd != null)
            Row(children: [
              Text(
                S.of(context).price,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Expanded(
                  child: AutoSizeText(
                FundFormatter.format(balance.balanceDisplay * finalPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(_currency),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: AutoSizeText(
              FundFormatter.format(balance.balanceDisplay),
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.right,
              maxLines: 1,
            )),
          ]),
          if (priceUsd != null && !_pricesLoading)
            Row(children: [
              Expanded(
                  child: AutoSizeText(
                FundFormatter.format(balance.balanceDisplay * finalPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(_currency),
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.right,
                maxLines: 1,
              )),
            ]),
          if (priceUsd != null && _pricesLoading)
            Row(children: [
              Expanded(
                  child: AutoSizeText(
                S.of(context).loading,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.right,
                maxLines: 1,
              )),
            ]),
        ])),
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
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 10),
          child: AppButton.buildAppButton(context, AppButtonType.PRIMARY, S.of(context).dfx_buy_title,
              onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DfxBuyScreen()))},
              icon: Icons.add_shopping_cart,
              key: const Key("buy_dfx"))),
      Expanded(
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                      var text = items.keys.toList()[section];
                      if (items.values.toList()[section].isEmpty) {
                        var noAccSelected = S.of(context).wallet_account_nothing_selected;
                        text += " ($noAccSelected)";
                      }
                      var balances = items.values.toList()[section].toList();

                      var totalUSD = balances.fold(0.0, (previousValue, balance) {
                        if (balance == null) {
                          return previousValue;
                        }

                        var price = _prices != null ? _prices.firstWhere((element) => element.token == balance.token, orElse: () => null) : null;
                        var priceUsd = price != null ? price.aggregated.amount : null;

                        if (balance.token.toLowerCase() == 'dusd') {
                          priceUsd = 1;
                        }

                        if (null == priceUsd) {
                          return previousValue;
                        }

                        return previousValue + (priceUsd * balance.balanceDisplay) * _tetherPrice;
                      });

                      var priceWidget;

                      if (_pricesLoading) {
                        priceWidget = Text(
                          S.of(context).loading,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right,
                        );
                      } else {
                        priceWidget = Text(
                          FundFormatter.format(totalUSD, fractions: 2) + ' ' + Currency.getCurrencySymbol(_currency),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right,
                        );
                      }

                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                text,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Expanded(child: priceWidget)
                            ],
                          ));
                    },
                    dragStartBehavior: DragStartBehavior.down,
                    separatorBuilder: (context, index) => SizedBox(height: 5),
                    sectionSeparatorBuilder: (context, section) => SizedBox(height: 5),
                  ))))
    ]);
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
                              _timer.cancel();
                              await _refresh();
                              _startTimer();
                            }
                          : null,
                    ))),
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AccountsScreen(allowChangeVisibility: false, allowImport: false)));
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
        body: PrimaryScrollController(controller: new ScrollController(), child: buildMultiWalletScreen(context)));
  }
}
