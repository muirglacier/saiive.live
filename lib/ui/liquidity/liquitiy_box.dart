import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/pool_share_liquidity.dart';
import 'package:defichainwallet/ui/liquidity/pool_share.dart';
import 'package:defichainwallet/ui/utils/token_pair_icon.dart';
import 'package:flutter/material.dart';

class LiquidityBoxWidget extends StatefulWidget {
  PoolShareLiquidity liquidity;

  LiquidityBoxWidget(this.liquidity);

  @override
  State<StatefulWidget> createState() {
    return _LiquidityBoxWidget();
  }
}

class _LiquidityBoxWidget extends State<LiquidityBoxWidget> {
  @override
  Widget build(Object context) {
    return InkWell(
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  PoolShareScreen(widget.liquidity)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: <Widget>[
                  Container(
                      decoration: new BoxDecoration(color: Colors.transparent),
                      child: TokenPairIcon(
                          widget.liquidity.tokenA, widget.liquidity.tokenB)),
                  Container(
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: Text('APY',
                              style: TextStyle(fontWeight: FontWeight.bold))),
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
                          child: Text(
                              (widget.liquidity.poolSharePercentage /
                                      100 *
                                      widget.liquidity.poolPair.reserveA)
                                  .toStringAsFixed(8),
                              textAlign: TextAlign.right))
                    ]),
                  ),
                  Container(
                    child: Row(children: [
                      Expanded(flex: 4, child: Text(widget.liquidity.tokenB)),
                      Expanded(
                          flex: 6,
                          child: Text(
                              (widget.liquidity.poolSharePercentage /
                                      100 *
                                      widget.liquidity.poolPair.reserveB)
                                  .toStringAsFixed(8),
                              textAlign: TextAlign.right))
                    ]),
                  ),
                  Container(
                      child: Row(children: [
                    Expanded(
                        flex: 4,
                        child:
                            Text(S.of(context).liquitiy_pool_share_percentage)),
                    Expanded(
                        flex: 6,
                        child: Text(
                            widget.liquidity.poolSharePercentage
                                    .toStringAsFixed(8) +
                                '%',
                            textAlign: TextAlign.right))
                  ])),
                ]))));
  }
}
