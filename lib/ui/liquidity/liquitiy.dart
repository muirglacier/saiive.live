import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/poolshare.dart';
import 'package:defichainwallet/network/model/pool_pair_liqudity.dart';
import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:defichainwallet/ui/utils/token_pair_icon.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiquidityScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LiquidityScreen();
  }
}

class _LiquidityScreen extends State<LiquidityScreen> {
  List<PoolPairLiquidity> _liquidity;

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    var liquidity = await new PoolShareHelper().getMyPoolShares('DFI', 'USD');

    setState(() {
      _liquidity = liquidity;
    });
  }

  Widget _buildMyLiquidityEntry(PoolPairLiquidity myLiquidity) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: <Widget>[
              Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  child: TokenPairIcon(myLiquidity.tokenA, myLiquidity.tokenB)),
              Container(
                child: Row(children: [
                  Expanded(
                      flex: 4,
                      child: Text('APY',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 6,
                      child: Text(
                        myLiquidity.apy.toStringAsFixed(2) + '%',
                        textAlign: TextAlign.right,
                        textScaleFactor: 3,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(myLiquidity.tokenA)),
                  Expanded(
                      flex: 6,
                      child: Text(
                          (myLiquidity.poolSharePercentage /
                                  100 *
                                  myLiquidity.poolPair.reserveA)
                              .toStringAsFixed(8),
                          textAlign: TextAlign.right))
                ]),
              ),
              Container(
                child: Row(children: [
                  Expanded(flex: 4, child: Text(myLiquidity.tokenB)),
                  Expanded(
                      flex: 6,
                      child: Text(
                          (myLiquidity.poolSharePercentage /
                                  100 *
                                  myLiquidity.poolPair.reserveB)
                              .toStringAsFixed(8),
                          textAlign: TextAlign.right))
                ]),
              ),
              Container(
                  child: Row(children: [
                Expanded(
                    flex: 4,
                    child: Text(S.of(context).liquitiy_pool_share_percentage)),
                Expanded(
                    flex: 6,
                    child: Text(
                        myLiquidity.poolSharePercentage.toStringAsFixed(8) +
                            '%',
                        textAlign: TextAlign.right))
              ])),
            ])));
  }

  buildMyLiqduitiyScreen(BuildContext context) {
    if (_liquidity == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(30),
        child: ListView(children: [
          Center(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _liquidity.length,
                  itemBuilder: (context, index) {
                    return _buildMyLiquidityEntry(_liquidity.elementAt(index));
                  }))
        ]));
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).liquitiy)),
        body: Scaffold(body: buildMyLiqduitiyScreen(context)));
  }
}
