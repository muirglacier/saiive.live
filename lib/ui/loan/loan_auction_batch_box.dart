import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';

class AuctionBatchBoxWidget extends StatefulWidget {
  final LoanVaultAuctionBatch batch;
  final List<String> publicKeys;

  final CurrencyEnum currency;
  final double tetherPrice;

  AuctionBatchBoxWidget(this.batch, this.currency, this.tetherPrice, {this.publicKeys});

  @override
  State<StatefulWidget> createState() {
    return _AuctionBatchBoxWidget();
  }
}

class _AuctionBatchBoxWidget extends State<AuctionBatchBoxWidget> {
  @override
  Widget build(Object context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(children: <Widget>[
            Container(decoration: BoxDecoration(color: Colors.transparent), child: TokenIcon(widget.batch.loan.symbol)),
            Container(width: 10),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Batch: " + widget.batch.index.toString() + " - " + widget.batch.loan.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline6,
              ),
              Row(children: [])
            ])),
            if (widget.batch.highestBid != null && widget.publicKeys.contains(widget.batch.highestBid.owner)) Container(width: 5),
            if (widget.batch.highestBid != null && widget.publicKeys.contains(widget.batch.highestBid.owner))
              Container(
                  child: Chip(
                label: Text(S.of(context).loan_auction_your_bid),
                backgroundColor: Colors.green,
              )),
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Text(S.of(context).loan_collateral_value, style: Theme.of(context).textTheme.caption),
              Text(S.of(context).loan_auction_highest_bid, style: Theme.of(context).textTheme.caption)
            ]),
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.batch.collaterals.map((element) {
                  return FundFormatter.format(element.amountDouble) + ' ' + element.symbol;
                }).join(' / ')),
                Text(FundFormatter.format(widget.batch.collateralValueUSD * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency))
              ]),
              widget.batch.highestBid != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(FundFormatter.format(widget.batch.highestBid.amount.amountDouble) + ' ' + widget.batch.loan.symbol),
                      Text(FundFormatter.format(widget.batch.highestBid.amount.valueUSD * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency))
                    ])
                  : Text('N/A')
            ])
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Text(S.of(context).loan_value, style: Theme.of(context).textTheme.caption),
              Text(S.of(context).loan_auction_min_bid, style: Theme.of(context).textTheme.caption),
            ]),
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(FundFormatter.format(widget.batch.loan.amountDouble) + ' ' + widget.batch.loan.symbol),
                Text(FundFormatter.format(widget.batch.loan.valueUSD * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(FundFormatter.format(widget.batch.loan.amountDouble * 1.05) + ' ' + widget.batch.loan.symbol),
                Text(FundFormatter.format(widget.batch.loan.valueUSD * widget.tetherPrice * 1.05, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency)),
              ]),
            ]),
          ])
        ]));
  }
}
