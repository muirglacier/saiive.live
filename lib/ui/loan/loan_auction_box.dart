import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/bus/stats_loaded_event.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/ui/loan/loan_auction.dart';
import 'package:saiive.live/ui/loan/loan_auction_batch_box.dart';
import 'package:flutter/material.dart';

class AuctionBoxWidget extends StatefulWidget {
  final LoanVaultAuction auction;
  final List<String> publicKeys;

  AuctionBoxWidget(this.auction, {this.publicKeys});

  @override
  State<StatefulWidget> createState() {
    return _AuctionBoxWidget();
  }
}

class _AuctionBoxWidget extends State<AuctionBoxWidget> {
  StreamSubscription<StatsLoadedEvent> _statsLoadedEvent;
  Stats _stats;

  @override
  void initState() {
    super.initState();

    _stats = sl<StatsBackgroundService>().get();

    if (_statsLoadedEvent == null) {
      _statsLoadedEvent = EventTaxiImpl.singleton().registerTo<StatsLoadedEvent>().listen((event) async {
        setState(() {
          _stats = event.stats;
        });
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_statsLoadedEvent != null) {
      _statsLoadedEvent.cancel();
      _statsLoadedEvent = null;
    }
  }

  @override
  Widget build(Object context) {
    List<AuctionBatchBoxWidget> batches = widget.auction.batches.map((e) => AuctionBatchBoxWidget(e, publicKeys: widget.publicKeys)).toList();

    return InkWell(
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultAuctionScreen(widget.auction, publicKeys: widget.publicKeys)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: <Widget>[
                    Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                    Container(width: 10),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        widget.auction.vaultId,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Wrap(children: [
                        Text(widget.auction.liquidationHeight.toString()),
                        if (_stats != null && null != widget.auction.calculateEndDate(_stats.count.blocks))
                          Text(' / ' + widget.auction.calculateRemainingBlocks(_stats.count.blocks).toString() + ' - ' + widget.auction.calculateEndDate(_stats.count.blocks))
                      ])
                    ])),
                    if (widget.publicKeys.contains(widget.auction.ownerAddress)) Container(width: 5),
                    if (widget.publicKeys.contains(widget.auction.ownerAddress))
                      Container(
                          child: Chip(
                        label: Text(S.of(context).loan_auction_your_vault),
                        backgroundColor: Colors.red,
                      )),
                  ]),
                  Container(height: 10),
                  ...batches
                ]))));
  }
}
