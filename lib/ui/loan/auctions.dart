import 'package:saiive.live/appcenter/appcenter.dart';
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

class AuctionsScreen extends RefreshableWidget {
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
}

class _AuctionsScreen extends State<AuctionsScreen> with AutomaticKeepAliveClientMixin<AuctionsScreen> {
  List<LoanVaultAuction> _auctions;

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
    });
  }

  buildAuctionScreen(BuildContext context) {
    if (_auctions == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    if (_auctions.length == 0) {
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

    var row = Responsive.buildResponsive<LoanVaultAuction>(context, _auctions, 500, (el) => new AuctionBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: LayoutBuilder(builder: (_, builder) {
      return buildAuctionScreen(context);
    }));
  }
}
