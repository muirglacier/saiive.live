import 'dart:async';

import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/pool_share_liquidity.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LiquidityRemoveScreen extends StatefulWidget {
  final PoolShareLiquidity liquidity;

  LiquidityRemoveScreen(this.liquidity);

  @override
  State<StatefulWidget> createState() {
    return _LiquidityRemoveScreen();
  }
}

class _LiquidityRemoveScreen extends State<LiquidityRemoveScreen> {
  @override
  void initState() {
    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openRemoveLiquidity", <String, String>{});

    myReserveA = (widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveA);
    myReserveB = (widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveB);

    toRemoveTokenA = myReserveA;
    toRemoveTokenB = myReserveB;

    _percentageTextController.addListener(handleChangePercentage);
  }

  double percentage = 100;
  double toRemoveTokenA = 0;
  double toRemoveTokenB = 0;
  double myReserveA = 0;
  double myReserveB = 0;

  var _percentageTextController = TextEditingController(text: '100');

  Future removeLiquidity() async {
    //TBD
  }

  handleChangePercentage() {
    double amount = double.tryParse(_percentageTextController.text);

    if (null == amount) {
      return;
    }

    setState(() {
      percentage = amount;
    });

    calculateRemoveValues();
  }

  calculateRemoveValues() {
    toRemoveTokenA = myReserveA * percentage / 100;
    toRemoveTokenB = myReserveB * percentage / 100;
  }

  @override
  void dispose() {
    // _amountTokenAController.dispose();
    super.dispose();
  }

  Widget _buildRemoveLmPage(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Column(children: [
        Row(children: [
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [
                FilteringTextInputFormatter(
                    RegExp(r"^(100(\.0{1,2})?|[1-9]?\d(\.\d{1,2})?)"),
                    allow: true)
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                  labelText: '', counterText: '', suffix: Text('%')),
              controller: _percentageTextController,
            ),
          ),
          Expanded(
              flex: 4,
              child: Slider(
                value: percentage,
                min: 0,
                max: 100,
                label: percentage.round().toString() + '%',
                onChanged: (double value) {
                  setState(() {
                    percentage = value;

                    _percentageTextController.text = value.toStringAsFixed(1);

                    calculateRemoveValues();
                  });
                },
              ))
        ]),
        SizedBox(height: 10),
        Row(children: [
          Expanded(
              flex: 4,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                TokenIcon(widget.liquidity.tokenA),
                SizedBox(width: 5),
                Text(widget.liquidity.tokenA)
              ])),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      toRemoveTokenA.toStringAsFixed(8) + ' ' + S.of(context).liquitiy_remove_of + ' ' + myReserveA.toStringAsFixed(8),
                      textAlign: TextAlign.right
                  ),
                ],
              )),
        ]),
        Divider(
          thickness: 2,
        ),
        Row(children: [
          Expanded(
              flex: 4,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                TokenIcon(widget.liquidity.tokenB),
                SizedBox(width: 5),
                Text(widget.liquidity.tokenB)
              ])),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      toRemoveTokenB.toStringAsFixed(8) + ' ' + S.of(context).liquitiy_remove_of + ' ' + myReserveB.toStringAsFixed(8),
                      textAlign: TextAlign.right
                  ),
                ],
              )),
        ]),
        Divider(
          thickness: 2,
        ),
        Row(children: [
          Expanded(flex: 4, child: Text(S.of(context).liquitiy_remove_price)),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.liquidity.poolPair.reserveADivReserveB.toStringAsFixed(8) + " " + widget.liquidity.tokenA + " per " + widget.liquidity.tokenB,
                    textAlign: TextAlign.right
                  ),
                  Text(
                      widget.liquidity.poolPair.reserveBDivReserveA.toStringAsFixed(8) + " " + widget.liquidity.tokenB + " per " + widget.liquidity.tokenA,
                      textAlign: TextAlign.right
                  )
                ],
              )),
        ]),
        SizedBox(height: 10),
        if (percentage > 0)
        ElevatedButton(
          child: Text(S.of(context).liquitiy_remove),
          onPressed: () async {
            await removeLiquidity();
          },
        )
      ])
    ]);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).liquitiy_remove)),
        body: Padding(padding: EdgeInsets.all(30), child: _buildRemoveLmPage(context)));
  }
}
