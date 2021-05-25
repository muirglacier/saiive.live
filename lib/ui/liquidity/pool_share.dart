import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/pool_share_liquidity.dart';
import 'package:defichainwallet/ui/liquidity/liquidity_remove.dart';
import 'package:defichainwallet/ui/utils/token_pair_icon.dart';
import 'package:flutter/material.dart';

class PoolShareScreen extends StatefulWidget {
  final PoolShareLiquidity liquidity;

  PoolShareScreen(this.liquidity);

  @override
  State<StatefulWidget> createState() {
    return _PoolShareScreen();
  }
}

class _PoolShareScreen extends State<PoolShareScreen> {
  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(widget.liquidity.tokenA + ' - ' + widget.liquidity.tokenB),
          actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LiquidityRemoveScreen(widget.liquidity)));
                  },
                  child: Icon(Icons.remove_circle_outline_outlined, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
                )),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Card(
                  child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(children: <Widget>[
                        Container(child: TokenPairIcon(widget.liquidity.tokenA, widget.liquidity.tokenB)),
                        Container(
                          child: Row(children: [
                            Expanded(flex: 2, child: Text('APY', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 10,
                                child: Text(
                                  widget.liquidity.apy.toStringAsFixed(2) + '%',
                                  textAlign: TextAlign.right,
                                  textScaleFactor: 2.5,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))
                          ]),
                        ),
                        Container(
                          child: Row(children: [
                            Expanded(flex: 4, child: Text(widget.liquidity.tokenA)),
                            Expanded(
                                flex: 6,
                                child: Text((widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveA).toStringAsFixed(8), textAlign: TextAlign.right))
                          ]),
                        ),
                        Container(
                          child: Row(children: [
                            Expanded(flex: 4, child: Text(widget.liquidity.tokenB)),
                            Expanded(
                                flex: 6,
                                child: Text((widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveB).toStringAsFixed(8), textAlign: TextAlign.right))
                          ]),
                        ),
                        Container(
                            child: Row(children: [
                          Expanded(flex: 4, child: Text(S.of(context).liquitiy_pool_share_percentage)),
                          Expanded(flex: 6, child: Text(widget.liquidity.poolSharePercentage.toStringAsFixed(8) + '%', textAlign: TextAlign.right))
                        ])),
                        Column(children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Container(
                            child: Row(children: [
                              Expanded(flex: 2, child: Text('Estimated Rewards', style: TextStyle(fontWeight: FontWeight.bold))),
                            ]),
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 4, child: Text('Per Block')),
                            Expanded(flex: 6, child: Text(widget.liquidity.blockReward.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  'DFI',
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 10, child: Text(widget.liquidity.blockRewardFiat.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  widget.liquidity.coin.currency,
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 4, child: Text('Per Minute')),
                            Expanded(flex: 10, child: Text(widget.liquidity.minuteReward.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  'DFI',
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 10, child: Text(widget.liquidity.minuteRewardFiat.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  widget.liquidity.coin.currency,
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 4, child: Text('Per Hour')),
                            Expanded(flex: 10, child: Text(widget.liquidity.hourlyReword.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  'DFI',
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 10, child: Text(widget.liquidity.hourlyRewordFiat.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  widget.liquidity.coin.currency,
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 4, child: Text('Per Day')),
                            Expanded(flex: 10, child: Text(widget.liquidity.dailyReward.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  'DFI',
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 10, child: Text(widget.liquidity.dailyRewardFiat.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  widget.liquidity.coin.currency,
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 4, child: Text('Per Year')),
                            Expanded(flex: 6, child: Text(widget.liquidity.yearlyReward.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  'DFI',
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                          Container(
                              child: Row(children: [
                            Expanded(flex: 10, child: Text(widget.liquidity.yearlyRewardFiat.toStringAsFixed(8), textAlign: TextAlign.right)),
                            SizedBox(
                                width: 40,
                                child: Text(
                                  widget.liquidity.coin.currency,
                                  textAlign: TextAlign.right,
                                ))
                          ])),
                        ])
                      ])))
            ])));
  }
}
