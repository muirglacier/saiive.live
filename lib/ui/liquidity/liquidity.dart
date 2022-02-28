import 'dart:async';
import 'dart:io';

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/poolpair.dart';
import 'package:saiive.live/helper/poolshare.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/network/stats.dart';
import 'package:saiive.live/network/events/wallet_sync_liquidity_data.dart';
import 'package:saiive.live/network/model/pool_pair_liquidity.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/prices_background.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/ui/liquidity/liquidity_add.dart';
import 'package:saiive.live/ui/liquidity/liquidity_box.dart';
import 'package:saiive.live/ui/utils/token_pair_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class LiquidityScreen extends StatefulWidget {
  const LiquidityScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LiquidityScreen();
  }
}

class _LiquidityScreen extends State<LiquidityScreen> {
  List<PoolShareLiquidity> _liquidity;
  List<PoolPairLiquidity> _poolPairLiquidity;
  var _formatCurrency = new NumberFormat.simpleCurrency();
  bool showEstimatedRewards = false;
  bool _isLoading = false;
  Stats _stats;

  double _tetherPrice = 1.0;
  CurrencyEnum _currency = CurrencyEnum.USD;

  StreamSubscription<WalletSyncLiquidityData> _refreshPoolDataSubscription;

  @override
  void deactivate() {
    super.deactivate();

    if (_refreshPoolDataSubscription != null) {
      _refreshPoolDataSubscription.cancel();
      _refreshPoolDataSubscription = null;
    }
  }

  @override
  void initState() {
    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openLiquidityPage", <String, String>{});
    sl.get<IHealthService>().checkHealth(context);

    if (_refreshPoolDataSubscription == null) {
      _refreshPoolDataSubscription = EventTaxiImpl.singleton().registerTo<WalletSyncLiquidityData>().listen((event) async {
        await _refresh();
      });
    }

    _init();
  }

  _init() async {
    _refresh();
  }

  _refresh() async {
    if (_isLoading) {
      return;
    }

    _tetherPrice = sl<PricesBackgroundService>().tetherPrice().fiat;
    _currency = await sl<ISharedPrefsUtil>().getCurrency();
    _formatCurrency = new NumberFormat.simpleCurrency(name: Currency.getCurrencyShortage(_currency));

    _stats = await sl<IStatsService>().getStats(DeFiConstants.DefiAccountSymbol);

    sl.get<AppCenterWrapper>().trackEvent("openLiquidityPageLoadStart", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});

    setState(() {
      _isLoading = true;
    });

    try {
      var liquidity = await new PoolShareHelper().getMyPoolShares('DFI', 'USD', _stats);
      var poolPairLiquidity = await new PoolPairHelper().getPoolPairs(
        'DFI',
        'USD',
      );

      if (!this.mounted) {
        return;
      }
      setState(() {
        _liquidity = liquidity;
        _poolPairLiquidity = poolPairLiquidity;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildPoolPairLiquidityEntry(PoolPairLiquidity liquidity) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 10.0), decoration: new BoxDecoration(color: Colors.transparent), child: TokenPairIcon(liquidity.tokenA, liquidity.tokenB)),
              Container(
                child: Row(children: [
                  Expanded(flex: 2, child: Text('APR', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 10,
                      child: Text(
                        (liquidity.apr != null ? liquidity.apr.toStringAsFixed(2) : 0.0.toStringAsFixed(2)) + '%',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(Currency.getCurrencyShortage(_currency) + ' ' + Currency.getCurrencySymbol(_currency))),
                  Expanded(flex: 6, child: Text(_formatCurrency.format(liquidity.totalLiquidityInUSDT * _tetherPrice), textAlign: TextAlign.right))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(liquidity.tokenA)),
                  Expanded(flex: 6, child: Text(FundFormatter.format(liquidity.poolPair.reserveA), textAlign: TextAlign.right))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(liquidity.tokenB)),
                  Expanded(flex: 6, child: Text(FundFormatter.format(liquidity.poolPair.reserveB), textAlign: TextAlign.right))
                ]),
              ),
            ])));
  }

  buildAllLiquidityScreen(BuildContext context) {
    if (_liquidity == null || _isLoading) {
      return LoadingWidget(text: S.of(context).loading);
    }

    var row = Responsive.buildResponsive<PoolShareLiquidity>(context, _liquidity, 500, (el) => new LiquidityBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Visibility(
                  visible: _liquidity.length > 0,
                  child: Center(child: Text(S.of(context).liqudity_your_liquidity, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold))))),
        ),
        SliverToBoxAdapter(child: Container(child: row)),
        SliverToBoxAdapter(
          child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Center(child: Text(S.of(context).liqudity_pool_pairs, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)))),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _buildPoolPairLiquidityEntry(_poolPairLiquidity.elementAt(index));
            },
            childCount: _poolPairLiquidity.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(
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
            Text(S.of(context).liquidity)
          ]),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LiquidityAddScreen()));
                  },
                  child: Icon(Icons.add, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                )),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    _refresh();
                  },
                  child: Icon(Icons.refresh, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                )),
          ],
        ),
        body: PrimaryScrollController(
            controller: new ScrollController(),
            child: LayoutBuilder(builder: (_, builder) {
              return buildAllLiquidityScreen(context);
            })));
  }
}
