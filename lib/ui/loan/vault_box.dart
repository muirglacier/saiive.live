import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/ui/loan/vault_detail.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_set_icon.dart';
import 'package:saiive.live/ui/widgets/vault_status.dart';

class VaultBoxWidget extends StatefulWidget {
  final LoanVault vault;
  final CurrencyEnum currency;
  final double tetherPrice;

  VaultBoxWidget(this.vault, this.currency, this.tetherPrice);

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
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultDetailScreen(widget.vault, widget.currency, widget.tetherPrice)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: widget.vault.state != LoanVaultStatus.in_liquidation
                    ? Column(children: [
                        vaultHead(),
                        Container(height: 10),
                        Table(border: TableBorder(), children: [
                          TableRow(children: [
                            Text(S.of(context).loan_active_loans, style: Theme.of(context).textTheme.caption),
                            Text(S.of(context).loan_total_loan_amount, style: Theme.of(context).textTheme.caption)
                          ]),
                          TableRow(children: [
                            Container(padding: new EdgeInsets.only(left: 5), child: TokenSetIcons(widget.vault.loanAmounts, 3)),
                            Text(FundFormatter.format(double.tryParse(widget.vault.loanValue) * widget.tetherPrice, fractions: 2) +
                                ' ' +
                                Currency.getCurrencySymbol(widget.currency))
                          ]),
                        ]),
                        Container(height: 10),
                        Table(border: TableBorder(), children: [
                          TableRow(children: [
                            Text(S.of(context).loan_collateral_amount, style: Theme.of(context).textTheme.caption),
                            Text(S.of(context).loan_collateral_ratio, style: Theme.of(context).textTheme.caption)
                          ]),
                          TableRow(children: [
                            Text(FundFormatter.format(double.tryParse(widget.vault.collateralValue) * widget.tetherPrice, fractions: 2) +
                                ' ' +
                                Currency.getCurrencySymbol(widget.currency)),
                            Text((widget.vault.collateralRatioDouble.toStringAsFixed(2) + '%' ?? '-') +
                                ' / ' +
                                (widget.vault.nextCollateralRatioDouble.toStringAsFixed(2) + '%' ?? '-'))
                          ]),
                        ]),
                      ])
                    : Column(children: [vaultHead()]))));
  }

  Widget vaultHead() {
    return Row(children: <Widget>[
      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
      Container(width: 10),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.vault.vaultId,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
        if (widget.vault.state != LoanVaultStatus.in_liquidation) Row(children: [Text(S.of(context).loan_collaterals), TokenSetIcons(widget.vault.collateralAmounts, 3)])
      ])),
      Container(width: 10),
      Container(decoration: BoxDecoration(color: Colors.transparent), child: VaultStatusWidget(widget.vault.healthStatus))
    ]);
  }
}
