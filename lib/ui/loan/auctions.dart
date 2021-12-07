import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
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


enum LoanVaultFilter { mine, buyable, bidder }

extension ParseToStringLoanVaultHealthStatus on LoanVaultFilter {
  String toText(BuildContext context) {
    switch (this) {
      case LoanVaultFilter.mine:
        {
          return S.of(context).loan_auction_filter_mine;
        }

      case LoanVaultFilter.buyable:
        {
          return S.of(context).loan_auction_filter_buyable;
        }

      case LoanVaultFilter.bidder:
        {
          return S.of(context).loan_auction_filter_highest_bidder;
        }
    }

    return '';
  }
}


class AuctionsScreen extends RefreshableWidget implements SearchableWidget {
  final _state = _AuctionsScreen();
  AuctionsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void refresh() {
    _state.refresh();
  }

  @override
  void search(String text) {
    _state._filterText = text;
    _state.filter();
  }

  void filter(Map<LoanVaultFilter, bool> filters) {
    _state._filters = filters;

    _state.filter();
  }
}

class _AuctionsScreen extends State<AuctionsScreen> with AutomaticKeepAliveClientMixin<AuctionsScreen> {
  List<LoanVaultAuction> _auctions;
  List<LoanVaultAuction> _filteredAuctions;
  List<AccountBalance> _accountBalance;
  List<String> _publicKeys;
  bool _loadedBalance = false;
  bool _loadedAuctions = false;
  String _filterText = "";
  Map<LoanVaultFilter, bool> _filters;

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

    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys(onlyActive: true);

    setState(() {
      _accountBalance = accountBalance;
      _publicKeys = pubKeyList;
      _loadedBalance = true;
    });
  }

  _initAuctions() async {
    setState(() {
      _auctions = null;
      _loadedAuctions = false;
    });

    var auctions = await sl.get<ILoansAuctionsService>().getAuctions(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _auctions = auctions;
      _loadedAuctions = true;
      _filteredAuctions = _auctions;
    });
  }

  refresh() async {
    await _initAuctions();
    filter();
  }

  filter() {
    var filtered = _auctions.where((element) {
      if (_filters != null && _filters.containsKey(LoanVaultFilter.mine) && _filters[LoanVaultFilter.mine]) {
        if (!_publicKeys.contains(element.ownerAddress)) {
          return false;
        }
      }

      return element.batches.where((batch) {
        if (_filters != null && _filters.containsKey(LoanVaultFilter.buyable) && _filters[LoanVaultFilter.buyable]) {
          var balance = _accountBalance.firstWhere((element) => element.token == batch.loan.symbol, orElse: () => null);

          if (null == balance) {
            return false;
          }

          if (balance.balanceDisplay < batch.minBid) {
            return false;
          }
        }

        if (_filters != null && _filters.containsKey(LoanVaultFilter.bidder) && _filters[LoanVaultFilter.bidder]) {
          if (null == batch.highestBid || !_publicKeys.contains(batch.highestBid.owner)) {
            return false;
          }
        }

        if (_filterText == "") {
          return true;
        }

        return batch.loan.symbol.toLowerCase().contains(_filterText);
      }).length > 0;
    }).toList();

    setState(() {
      _filteredAuctions = filtered;
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
                    Container(child: Text(S.of(context).loan_no_auctions, style: Theme.of(context).textTheme.headline3), padding: new EdgeInsets.only(top: 5)),
                  ],
                )))
      ]);
    }

    var row = Responsive.buildResponsive<LoanVaultAuction>(context, _filteredAuctions, 500, (el) => new AuctionBoxWidget(el, publicKeys: _publicKeys));

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
