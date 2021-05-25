import 'dart:async';

import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:defichainwallet/helper/poolpair.dart';
import 'package:defichainwallet/helper/poolshare.dart';
import 'package:defichainwallet/network/events/wallet_sync_done_event.dart';
import 'package:defichainwallet/network/events/wallet_sync_liquidity_data.dart';
import 'package:defichainwallet/network/model/pool_pair_liquidity.dart';
import 'package:defichainwallet/network/model/pool_share_liquidity.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/services/health_service.dart';
import 'package:defichainwallet/ui/widgets/responsive.dart';
import 'package:defichainwallet/ui/liquidity/liquidity_add.dart';
import 'package:defichainwallet/ui/liquidity/liquidity_box.dart';
import 'package:defichainwallet/ui/utils/token_pair_icon.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class LiquidityScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LiquidityScreen();
  }
}

class _LiquidityScreen extends State<LiquidityScreen> {
  List<PoolShareLiquidity> _liquidity;
  List<PoolPairLiquidity> _poolPairLiquidity;
  final formatCurrency = new NumberFormat.simpleCurrency();
  bool showEstimatedRewards = false;
  bool _isLoading = false;

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
    _init();

    if (_refreshPoolDataSubscription == null) {
      _refreshPoolDataSubscription = EventTaxiImpl.singleton().registerTo<WalletSyncLiquidityData>().listen((event) async {
        await _refresh();
      });
    }
  }

  _init() async {
    _refresh();
  }

  _refresh() async {
    if (_isLoading) {
      return;
    }
    sl.get<AppCenterWrapper>().trackEvent("openLiquidityPageLoadStart", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});

    setState(() {
      _isLoading = true;
    });

    try {
      var liquidity = await new PoolShareHelper().getMyPoolShares('DFI', 'USD');
      var poolPairLiquidity = await new PoolPairHelper().getPoolPairs('DFI', 'USD');

      setState(() {
        _liquidity = liquidity;
        _poolPairLiquidity = poolPairLiquidity;
        _isLoading = false;
      });

      sl.get<AppCenterWrapper>().trackEvent("openLiquidityPageLoadEnd", <String, String>{"timestamp": DateTime.now().millisecondsSinceEpoch.toString()});
    } catch (e) {
      LogHelper.instance.e("Error loading data", e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));

      setState(() {
        _isLoading = false;
      });
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
                  Expanded(flex: 2, child: Text('APY', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 10,
                      child: Text(
                        liquidity.apy.toStringAsFixed(2) + '%',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(liquidity.tokenA)),
                  Expanded(flex: 6, child: Text(formatCurrency.format(liquidity.totalLiquidityInUSDT), textAlign: TextAlign.right))
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
          title: Text(S.of(context).liquidity),
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
        body: LayoutBuilder(builder: (_, builder) {
          return buildAllLiquidityScreen(context);
        }));
  }
}
