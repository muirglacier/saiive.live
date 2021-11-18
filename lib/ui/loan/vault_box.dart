import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/ui/loan/vault_detail.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
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
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  VaultDetailScreen(widget.vault)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  Row(children: <Widget>[
                    Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: Icon(Icons.shield, size: 40)),
                    Container(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            widget.vault.vaultId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Row(children: [
                            Text('Collaterals'),
                            TokenSetIcons(widget.vault.collateralAmounts, 3)
                          ])
                        ])),
                    Container(width: 10),
                    Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: InputChip(
                          label: Text(widget.vault.healthStatus.toShortString()),
                          onSelected: (bool value) {},
                        ))
                  ]),
                  Container(height: 10),
                  Table(border: TableBorder(), children: [
                    TableRow(children: [
                      Text('Active Loans',
                          style: Theme.of(context).textTheme.caption),
                      Text('Total Loan Amount',
                          style: Theme.of(context).textTheme.caption)
                    ]),
                    TableRow(children: [
                      Container(
                          padding: new EdgeInsets.only(left: 5),
                          child: TokenSetIcons(widget.vault.loanAmounts, 3)),
                      Text(widget.vault.loanAmounts.fold(
                          "0",
                          (sum, next) => (double.tryParse(sum) +
                                  double.tryParse(next.amount))
                              .toString()))
                    ]),
                  ]),
                  Container(height: 10),
                  Table(border: TableBorder(), children: [
                    TableRow(children: [
                      Text('Collateral Amount',
                          style: Theme.of(context).textTheme.caption),
                      Text('Collateral Ratio',
                          style: Theme.of(context).textTheme.caption)
                    ]),
                    TableRow(children: [
                      Text(FundFormatter.format(double.tryParse(widget.vault.collateralValue), fractions: 2) + '\$'),
                      Text(widget.vault.collateralRatio ?? '')
                    ]),
                  ]),
                ]))));
  }
}
