import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:intl/intl.dart';
import 'package:saiive.live/bus/stats_loaded_event.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/ui/loan/loan_auction.dart';
import 'package:saiive.live/ui/loan/loan_auction_batch_box.dart';
import 'package:flutter/material.dart';

class AuctionBoxWidget extends StatefulWidget {
  final LoanVaultAuction auction;

  AuctionBoxWidget(this.auction);

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

  String calculateEndDate() {
    if (null == _stats) {
      return null;
    }

    if (_stats.count.blocks > widget.auction.liquidationHeight) {
      return null;
    }

    var now = DateTime.now();
    now.add(Duration(seconds: ((widget.auction.liquidationHeight - _stats.count.blocks) / 2).floor()));
    final f = new DateFormat('dd.MM.yyyy hh:mm');

    return f.format(now);
  }

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
                          ),
                          Wrap(children: [
                            Text(widget.auction.liquidationHeight.toString()),
                            if (_stats != null && null != calculateEndDate()) Text(' / ' + calculateEndDate())
                          ])
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
