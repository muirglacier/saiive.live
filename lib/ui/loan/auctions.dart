import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/loans_auctions_service.dart';
import 'package:saiive.live/network/model/account_balance.dart';
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

  void toggleFilterBuyable(bool buyable) {
    _state.toggleFilterBuyable(buyable);
  }
}

class _AuctionsScreen extends State<AuctionsScreen> with AutomaticKeepAliveClientMixin<AuctionsScreen> {
  List<LoanVaultAuction> _auctions;
  List<LoanVaultAuction> _filteredAuctions;
  List<AccountBalance> _accountBalance;
  bool _loadedBalance = false;
  bool _loadedAuctions = false;
  bool _filterBuyable = false;
  String _filterText = "";

  @override
  void initState() {
    super.initState();

    _initAuctions();
    _loadBalance();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  _loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    setState(() {
      _accountBalance = accountBalance;
      _loadedBalance = true;
    });
  }

  _initAuctions() async {
    setState(() {
      _auctions = null;
    });

    var auctions = await sl.get<ILoansAuctionsService>().getAuctions(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _auctions = auctions;
      _loadedAuctions = true;
      _filteredAuctions = _auctions;
    });
  }

  void toggleFilterBuyable(bool buyable) {
    _filterBuyable = buyable;

    _filter(_filterText);
  }

  _filter(String text) {
    var filtered = _auctions.where((element) {
      return element.batches.where((batch) {
        if (_filterBuyable) {
          var balance = _accountBalance.firstWhere((element) => element.token == batch.loan.symbol, orElse: () => null);

          if (null == balance) {
            return false;
          }

          if (balance.balanceDisplay < batch.minBid) {
            return false;
          }

          if (text == "") {
            return true;
          }
        }

        return batch.loan.symbol.toLowerCase().contains(text);
      }).length > 0;
    }).toList();

    setState(() {
      _filteredAuctions = filtered;
      _filterText = text;
    });
  }

  buildAuctionScreen(BuildContext context) {
    if (!_loadedBalance || !_loadedAuctions) {
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
