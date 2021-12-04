import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/ui/loan/loan_auction.dart';
import 'package:saiive.live/ui/loan/loan_auction_batch_box.dart';
import 'package:saiive.live/ui/loan/vault_detail.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_set_icon.dart';
import 'package:saiive.live/ui/widgets/vault_status.dart';

class AuctionBoxWidget extends StatefulWidget {
  final LoanVaultAuction auction;

  AuctionBoxWidget(this.auction);

  @override
  State<StatefulWidget> createState() {
    return _AuctionBoxWidget();
  }
}

class _AuctionBoxWidget extends State<AuctionBoxWidget> {
  @override
  Widget build(Object context) {
    List<AuctionBatchBoxWidget> batches = widget.auction.batches.map((e) => AuctionBatchBoxWidget(e)).toList();

    return InkWell(
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  VaultAuctionScreen(widget.auction)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(20),
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
                            widget.auction.vaultId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ])),
                    Container(width: 10),
                    Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                    )
                  ]),
                  Container(height: 10),
                  ...batches
                ]))));
  }
}
