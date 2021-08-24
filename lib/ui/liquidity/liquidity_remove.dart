import 'dart:async';

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/events/wallet_sync_liquidity_data.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';
import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock/wakelock.dart';

class LiquidityRemoveScreen extends StatefulWidget {
  final PoolShareLiquidity liquidity;

  LiquidityRemoveScreen(this.liquidity);

  @override
  State<StatefulWidget> createState() {
    return _LiquidityRemoveScreen();
  }
}

class _LiquidityRemoveScreen extends State<LiquidityRemoveScreen> {
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openRemoveLiquidity", <String, String>{});

    myReserveA = (widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveA);
    myReserveB = (widget.liquidity.poolSharePercentage / 100 * widget.liquidity.poolPair.reserveB);

    toRemoveTokenA = myReserveA;
    toRemoveTokenB = myReserveB;

    for (final share in widget.liquidity.poolShares) {
      totalAmount += share.amount;
    }

    handleChangePercentage();
    _percentageTextController.addListener(handleChangePercentage);
  }

  double percentage = 100;
  double toRemoveTokenA = 0;
  double toRemoveTokenB = 0;
  double myReserveA = 0;
  double myReserveB = 0;
  double amountToRemove = 0;

  var _percentageTextController = TextEditingController(text: '100');

  Future removeLiquidity() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    var totalToRemove = amountToRemove;
    var hasError = false;

    dynamic lastError;
    TransactionData lastTx;
    for (final poolShare in widget.liquidity.poolShares) {
      var amount = poolShare.amount;

      if (totalToRemove < amount) {
        amount = totalToRemove;
      }

      var streamController = StreamController<String>();
      var createRemoveFuture = wallet.createAndSendRemovePoolLiquidity(int.parse(poolShare.poolID), (amount * 100000000).toInt(), poolShare.owner, loadingStream: streamController);
      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

      try {
        lastTx = await overlay.during(createRemoveFuture);
      } catch (error) {
        LogHelper.instance.e("removepool-tx error...($error)");
        hasError = true;
        lastError = error;
      } finally {
        streamController.close();
      }

      totalToRemove -= amount;

      if (totalToRemove <= 0) {
        break;
      }
    }

    EventTaxiImpl.singleton().fire(WalletSyncLiquidityData());
    if (hasError || totalToRemove > 0) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: lastError),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(lastTx.txId, S.of(context).liquidity_remove_successfull),
      ));

      Navigator.popUntil(context, ModalRoute.withName('/home'));
    }

    Wakelock.disable();
  }

  handleChangePercentage() {
    double amount = double.tryParse(_percentageTextController.text);

    if (amount == null) {
      return;
    }

    setState(() {
      percentage = amount;
      amountToRemove = (totalAmount / 100) * amount;
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
                inputFormatters: [FilteringTextInputFormatter(RegExp(r"^(100(\.0{1,2})?|[1-9]?\d(\.\d{1,2})?)"), allow: true)],
                textAlign: TextAlign.right,
                decoration: InputDecoration(labelText: '', counterText: '', suffix: Text('%')),
                controller: _percentageTextController),
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
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [TokenIcon(widget.liquidity.tokenA), SizedBox(width: 5), Text(widget.liquidity.tokenA)])),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(FundFormatter.format(toRemoveTokenA) + ' ' + S.of(context).liquidity_remove_of + ' ' + FundFormatter.format(myReserveA), textAlign: TextAlign.right),
                ],
              )),
        ]),
        Divider(
          thickness: 2,
        ),
        Row(children: [
          Expanded(
              flex: 4,
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [TokenIcon(widget.liquidity.tokenB), SizedBox(width: 5), Text(widget.liquidity.tokenB)])),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(FundFormatter.format(toRemoveTokenB) + ' ' + S.of(context).liquidity_remove_of + ' ' + FundFormatter.format(myReserveB), textAlign: TextAlign.right),
                ],
              )),
        ]),
        Divider(
          thickness: 2,
        ),
        Row(children: [
          Expanded(flex: 4, child: Text(S.of(context).liquidity_remove_price)),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(FundFormatter.format(widget.liquidity.poolPair.reserveADivReserveB) + " " + widget.liquidity.tokenA + " per " + widget.liquidity.tokenB,
                      textAlign: TextAlign.right),
                  Text(FundFormatter.format(widget.liquidity.poolPair.reserveBDivReserveA) + " " + widget.liquidity.tokenB + " per " + widget.liquidity.tokenA,
                      textAlign: TextAlign.right)
                ],
              )),
        ]),
        SizedBox(height: 10),
        if (percentage > 0)
          ElevatedButton(
            child: Text(S.of(context).liquidity_remove),
            onPressed: () async {
              await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                await removeLiquidity();
              });
            },
          )
      ])
    ]);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).liquidity_remove)),
        body: Padding(padding: EdgeInsets.all(30), child: _buildRemoveLmPage(context)));
  }
}
