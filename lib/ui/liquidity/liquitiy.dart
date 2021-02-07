import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/helper/poolshare.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/dex_service.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/pool_pair_liqudity.dart';
import 'package:defichainwallet/network/model/token_balance.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        child: ListTile(
          leading: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.account_balance_wallet)]),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(myLiquidity.poolPair.symbol,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
              ]),
          trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text((myLiquidity.apy).toStringAsFixed(2) + '%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
              ]),
        ));
  }

  buildMyLiqduitiyScreen(BuildContext context) {
    if (_liquidity == null) {
      return;
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
        appBar: AppBar(title: Text(S
            .of(context)
            .liquitiy)),
        body: Scaffold(body: buildMyLiqduitiyScreen(context))
    );
  }
}
