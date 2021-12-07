import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_auctions_service.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/loan_auction_box.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/util/refresh_able_widget.dart';
import 'package:saiive.live/util/search_able_widget.dart';

class AuctionsScreen extends RefreshableWidget implements SearchableWidget {
  final _state = _AuctionsScreen();
  AuctionsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void refresh() {
    _state._initAuctions();
  }

  @override
  void search(String text) {
    _state._filter(text);
  }
}

class _AuctionsScreen extends State<AuctionsScreen> with AutomaticKeepAliveClientMixin<AuctionsScreen> {
  List<LoanVaultAuction> _auctions;
  List<LoanVaultAuction> _filteredAuctions;

  @override
  void initState() {
    super.initState();

    _initAuctions();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  _initAuctions() async {
    setState(() {
      _auctions = null;
    });

    var auctions = await sl.get<ILoansAuctionsService>().getAuctions(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _auctions = auctions;
      _filteredAuctions = _auctions;
    });
  }

  _filter(String text) {
    var filtered = _auctions.where((element) {
      var batches = element.batches.where((batch) => batch.loan.symbol.contains(text));

      return batches.length > 0;
    }).toList();

    setState(() {
      _filteredAuctions = filtered;
    });
  }

  buildAuctionScreen(BuildContext context) {
    if (_filteredAuctions == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    if (_filteredAuctions.length == 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: Container(
                padding: new EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.account_balance, size: 64),
                    Container(child: Text('No Auctions currently', style: Theme.of(context).textTheme.headline3), padding: new EdgeInsets.only(top: 5)),
                  ],
                )))
      ]);
    }

    var row = Responsive.buildResponsive<LoanVaultAuction>(context, _filteredAuctions, 500, (el) => new AuctionBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[SliverToBoxAdapter(child: Container(child: row))],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: PrimaryScrollController(
            controller: new ScrollController(),
            child: LayoutBuilder(builder: (_, builder) {
              return buildAuctionScreen(context);
            })));
  }
}
