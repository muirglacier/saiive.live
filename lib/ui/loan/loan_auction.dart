import 'dart:async';
import 'dart:math';

import 'package:event_taxi/event_taxi.dart';
import 'package:intl/intl.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/bus/stats_loaded_event.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/ui/loan/loan_auction_batch_box.dart';
import 'package:saiive.live/ui/loan/loan_auction_bid.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/navigated.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class VaultAuctionScreen extends StatefulWidget {
  final LoanVaultAuction auction;
  final key = GlobalKey();

  VaultAuctionScreen(this.auction);

  @override
  State<StatefulWidget> createState() {
    return _VaultAuctionScreen();
  }
}

class _VaultAuctionScreen extends State<VaultAuctionScreen> {
  PanelController _panelController = PanelController();
  Widget _panel = Container();
  List<AccountBalance> _accountBalance;
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

    _loadBalance();
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
    now.add(Duration(seconds: (max(widget.auction.liquidationHeight - _stats.count.blocks, 0)*30).floor()));
    final f = new DateFormat('dd.MM.yyyy hh:mm');

    return f.format(now);
  }

  _loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    var filteredBalance = accountBalance.where((element) => element.chain == ChainType.DeFiChain).toList();

    setState(() {
      _accountBalance = filteredBalance;
    });
  }

  doPlaceBid(String vaultId, int index, String token, int amount, {String from}) async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();
    var streamController = StreamController<String>();

    try {
      var createVault = wallet.placeAuctionBid(vaultId, index, token, amount, from: from, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createVault);

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, "Auction bid set..."),
      ));

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      streamController.close();
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      Wakelock.disable();
    }
  }

  Widget _buildBidPanel(LoanVaultAuctionBatch batch) {
    var balance = _accountBalance.firstWhere((element) => element.token == batch.loan.symbol, orElse: () => null);

    return Navigated(
        child: VaultAuctionBidScreen(widget.auction, batch, balance, (amount, from) async {
      await doPlaceBid(widget.auction.vaultId, batch.index, balance.token, (amount * 100000000).round(), from: from);
    }));
  }

  Widget _buildTopPart() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: <Widget>[
                        Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                        Container(width: 10),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            widget.auction.vaultId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Wrap(children: [Text(widget.auction.liquidationHeight.toString()), if (_stats != null && null != calculateEndDate()) Text(' / ' + calculateEndDate())])
                        ])),
                        Container(width: 10)
                      ],
                    ),
                  ])))
        ]));
  }

  _buildBatchEntry(LoanVaultAuctionBatch batch) {
    return InkWell(
        onTap: () {
          setState(() {
            _panel = this._buildBidPanel(batch);
          });

          _panelController.show();
          _panelController.open();
        },
        child: Padding(padding: EdgeInsets.all(10), child: Card(child: AuctionBatchBoxWidget(batch))));
  }

  @override
  Widget build(BuildContext context) {
    if (_accountBalance == null) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_add_collateral_title)),
          body: LoadingWidget(text: S.of(context).loading));
    }

    GlobalKey<NavigatorState> key = GlobalKey();

    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Auction')),
      body: SlidingUpPanel(
          controller: _panelController,
          backdropEnabled: true,
          defaultPanelState: PanelState.CLOSED,
          minHeight: 0,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          color: StateContainer.of(context).curTheme.cardBackgroundColor,
          onPanelClosed: () {
            if (key != null && key.currentState != null && key.currentState.canPop()) {
              key.currentState.pop();
            }

            setState(() {
              _panel = Container();
            });
          },
          panel: LayoutBuilder(builder: (_, builder) {
            return Column(children: [
              SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(color: StateContainer.of(context).curTheme.backgroundColor, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              Expanded(child: _panel)
            ]);
          }),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopPart()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final batch = widget.auction.batches.elementAt(index);
                    return _buildBatchEntry(batch);
                  },
                  childCount: widget.auction.batches.length,
                ),
              )
            ],
          )),
    );
  }
}
