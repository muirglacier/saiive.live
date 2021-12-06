import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';

class AuctionBatchBoxWidget extends StatefulWidget {
  final LoanVaultAuctionBatch batch;

  AuctionBatchBoxWidget(this.batch);

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
            Container(width: 10),
            Container(
              decoration: BoxDecoration(color: Colors.transparent),
            )
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [Text('Collateral Value', style: Theme.of(context).textTheme.caption), Text('Highest bid', style: Theme.of(context).textTheme.caption)]),
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Text(FundFormatter.format(widget.batch.collateralValueUSD, fractions: 2) + ' \$'),
              Text(widget.batch.highestBid != null ? FundFormatter.format(widget.batch.highestBid.amount.valueUSD, fractions: 2) + ' \$' : 'N/A')
            ])
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Text('Loan Value', style: Theme.of(context).textTheme.caption),
              Text('Min Bid Value', style: Theme.of(context).textTheme.caption),
            ]),
          ]),
          Container(height: 10),
          Table(border: TableBorder(), children: [
            TableRow(children: [
              Text(FundFormatter.format(widget.batch.loan.valueUSD, fractions: 2) + ' \$'),
              Text(FundFormatter.format(widget.batch.loan.valueUSD * 1.05, fractions: 2) + ' \$'),
            ]),
          ])
        ]));
  }
}
