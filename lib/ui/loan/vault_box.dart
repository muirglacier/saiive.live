import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';
import 'package:saiive.live/ui/liquidity/pool_share.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_pair_icon.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/token_set_icon.dart';

class VaultBoxWidget extends StatefulWidget {
  final LoanVault vault;

  VaultBoxWidget(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultBoxWidget();
  }
}

class _VaultBoxWidget extends State<VaultBoxWidget> {
  @override
  Widget build(Object context) {
    return InkWell(
        onTap: () async {
          //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PoolShareScreen(widget.liquidity)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  Row(children: <Widget>[
                    Container(
                        decoration:
                            new BoxDecoration(color: Colors.transparent),
                        child: Icon(Icons.shield)),
                    Flexible(
                      child: new Container(
                        padding: new EdgeInsets.only(left: 15, right: 13.0),
                        child: new Text(
                          widget.vault.vaultId,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  ]),
                  Row(children: [
                    Text('Collaterals:'),
                    Container(
                        padding: new EdgeInsets.only(left: 5),
                        child: TokenSetIcons(widget.vault.collateralAmounts, 3))
                  ]),
                  Column(children: [
                    Row(children: [
                      Text('Active Loans'),
                      Container(
                          padding: new EdgeInsets.only(left: 5),
                          child: TokenSetIcons(widget.vault.loanAmounts, 3))
                    ]),
                    Row(children: [
                      Text('Total Loan Amount'),
                      Container(
                          padding: new EdgeInsets.only(left: 5),
                        child: Text( widget.vault.loanAmounts.fold("0", (sum, next) => (double.tryParse(sum) + double.tryParse(next.amount)).toString()))),
                    ]),
                    Row(children: [
                      Text('Collateral Amount'),
                      Container(
                          padding: new EdgeInsets.only(left: 5),
                          child: Text( widget.vault.collateralAmounts.fold("0", (sum, next) => (double.tryParse(sum) + double.tryParse(next.amount)).toString())),
                      )]),
                    Row(children: [
                      Text('Collateral Ratio'),
                      Container(
                          padding: new EdgeInsets.only(left: 5),
                          child: Text(widget.vault.collateralRatio)),
                    ])

                  ])
                ]))));
  }
}
