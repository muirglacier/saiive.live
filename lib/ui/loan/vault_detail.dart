import 'dart:async';
import 'dart:math';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_add_collateral.dart';
import 'package:saiive.live/ui/loan/vault_borrow_loan.dart';
import 'package:saiive.live/ui/loan/vault_edit_scheme.dart';
import 'package:saiive.live/ui/loan/vault_payback_loan.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/loan_collaterals.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/token_set_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:saiive.live/ui/widgets/vault_status.dart';
import 'package:wakelock/wakelock.dart';

class VaultDetailScreen extends StatefulWidget {
  final LoanVault vault;

  VaultDetailScreen(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultDetailScreen();
  }
}

class _VaultDetailScreen extends State<VaultDetailScreen> with TickerProviderStateMixin {
  final bodyGlobalKey = GlobalKey();
  TabController _tabController;
  ScrollController _scrollController;
  bool fixedScroll;
  bool isDFILessThan50 = false;
  List<LoanCollateral> _tokens;
  List<LoanToken> _loanTokens;
  bool _loading = false;
  bool _canEditCollateral = true;
  int _length = 0;

  LoanVault myVault;

  Future refreshVault() async {
    setState(() {
      _loading = true;
    });

    var vaults = await sl.get<IVaultsService>().getMyVault(DeFiConstants.DefiAccountSymbol, widget.vault.ownerAddress);

    var myNewVault = vaults.firstWhere((element) => element.vaultId == myVault.vaultId);

    if (myNewVault != null) {
      setState(() {
        myVault = myNewVault;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();

    myVault = widget.vault;

    super.initState();

    _initTokens();

    _canEditCollateral = widget.vault.state != LoanVaultStatus.in_liquidation && widget.vault.state != LoanVaultStatus.unknown && widget.vault.state != LoanVaultStatus.frozen;
    _length = widget.vault.state != LoanVaultStatus.in_liquidation ? 3 : 1;

    _tabController = TabController(length: _length, vsync: this);
    _tabController.addListener(_smoothScrollToTop);
  }

  void didUpdateWidget(covariant VaultDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vault.state != oldWidget.vault.state) {
      _length = widget.vault.state != LoanVaultStatus.in_liquidation ? 3 : 1;

      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: _length,
        initialIndex: max(0, min(oldIndex, _length - 1)),
        vsync: this,
      );
      _tabController.addListener(_smoothScrollToTop);
    }
  }

  List<Widget> buildChilds() {
    if (widget.vault.state != LoanVaultStatus.in_liquidation) {
      return  [
        _buildTabActiveLoans(),
        _buildTabDetails(),
        _buildTabCollaterals(),
        /*_buildTabAuctions()*/
      ];
    }
    return [
      _buildTabDetails(),
      /*_buildTabAuctions()*/
    ];
  }

  List<Widget> buildChildsTabs() {
    if (widget.vault.state != LoanVaultStatus.in_liquidation) {
      return  [
        Tab(text: S.of(context).loan_vault_details_tab_active_loan),
        Tab(text: S.of(context).loan_vault_details_tab_details),
        Tab(text: S.of(context).loan_vault_details_tab_collaterals),
        // Tab(text: S.of(context).loan_vault_details_tab_auctions),
      ];
    }
    return [
      Tab(text: S.of(context).loan_vault_details_tab_details),
      // Tab(text: S.of(context).loan_vault_details_tab_auctions),
    ];
  }

  _initTokens() async {
    setState(() {
      _tokens = null;
      _loanTokens = null;
    });
    try {
      var tokens = await sl.get<ILoansService>().getLoanCollaterals(DeFiConstants.DefiAccountSymbol);
      var loanTokens = await sl.get<ILoansService>().getLoanTokens(DeFiConstants.DefiAccountSymbol);

      setState(() {
        _tokens = tokens;
        _loanTokens = loanTokens;
      });
    } catch (error) {
      sl.get<AppCenterWrapper>().trackEvent("loadVaultDetailsError", <String, String>{"error": error.toString()});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    }
    _calculateDFIPercentage();
  }

  _calculateDFIPercentage() {
    var amount = myVault.collateralAmounts.firstWhere((element) => element.symbol == 'DFI', orElse: () => null);
    var token = _tokens.firstWhere((element) => element.token.symbol == 'DFI', orElse: () => null);
    var percentage = 0.0;

    if (null != amount && null != token) {
      percentage = LoanHelper.calculateCollateralShare(double.tryParse(myVault.collateralValue), amount, token);
    }

    setState(() {
      isDFILessThan50 = myVault.state != LoanVaultStatus.in_liquidation && percentage < 50.0;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(microseconds: 300),
      curve: Curves.ease,
    );
  }

  _buildTabActiveLoans() {
    if (myVault.loanAmounts.length == 0) {
      return Column(children: [
        Text(S.of(context).loan_no_active_loans),
        Container(height: 10),
        ElevatedButton(
          child: Text(S.of(context).loan_borrow),
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultBorrowLoan(loanVault: myVault)));
            await refreshVault();
          },
        )
      ]);
    }

    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildLoanEntry(myVault.loanAmounts.elementAt(index));
          },
          childCount: myVault.loanAmounts.length,
        ),
      )
    ]);
  }

  _doCloseVault() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();
    var streamController = StreamController<String>();

    try {
      var closeVault = wallet.closeVault(myVault.vaultId, myVault.ownerAddress, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(closeVault);

      EventTaxiImpl.singleton().fire(VaultSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, S.of(context).loan_close_vault_success),
      ));

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      streamController.close();
      Wakelock.disable();
    }
  }

  _buildLoanEntry(LoanVaultAmount amount) {
    var pricePerToken = amount.activePrice != null ? amount.activePrice.active.amount : 1.0;
    var totalAmount = pricePerToken * double.tryParse(amount.amount);
    var token = _loanTokens.firstWhere((element) => element.token.symbol == amount.symbol, orElse: () => null);
    var interest = myVault.interestAmounts.firstWhere((element) => element.symbol == amount.symbol, orElse: () => null);

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[TokenIcon(amount.symbol), Container(width: 5), Text(amount.displaySymbol)]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_borrowed_tokens, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_interest_amount + ' (${myVault.schema.interestRate} %)', style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(double.tryParse(amount.amount))),
                  Text(FundFormatter.format(double.tryParse(amount.amount) * double.tryParse(myVault.schema.interestRate) / 100, fractions: 4) + ' \$')
                ]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_amount_payable, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_price_per_token, style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [Text(FundFormatter.format(totalAmount, fractions: 2) + ' \$'), Text(FundFormatter.format(pricePerToken, fractions: 2) + ' \$')]),
              ]),
              Container(height: 10),
              Wrap(crossAxisAlignment: WrapCrossAlignment.start, children: [
                ElevatedButton(
                  child: Text(S.of(context).loan_payback_loan),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultPaybackLoanScreen(amount, token, myVault, interest)));
                    await refreshVault();
                  },
                ),
                Container(width: 10),
                ElevatedButton(
                  child: Text(S.of(context).loan_borrow_more),
                  onPressed: token == null
                      ? null
                      : () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultBorrowLoan(loanToken: token, loanVault: myVault)));
                          await refreshVault();
                        },
                )
              ])
            ])));
  }

  _buildTabDetails() {
    List<List<String>> items = [
      [S.of(context).loan_min_collateral_ratio, myVault.schema.minColRatio + '%'],
      [S.of(context).loan_vault_interest, myVault.schema.interestRate + '%'],
    ];

    List<List<String>> itemsVault = [];

    if (widget.vault.state != LoanVaultStatus.in_liquidation) {
      itemsVault = [
        [S.of(context).loan_collateral_ratio, myVault.collateralRatio + '%'],
        [S.of(context).loan_active_loans, myVault.loanAmounts.length.toString()],
        [S.of(context).loan_total_loan_amount, myVault.loanAmounts.fold("0", (sum, next) => (double.tryParse(sum) + double.tryParse(next.amount)).toString())],
        [S.of(context).loan_collateral_value, FundFormatter.format(double.tryParse(myVault.collateralValue), fractions: 2) + ' \$'],
        [S.of(context).loan_vault_health, myVault.healthStatus.toString()],
      ];
    }


    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_vault_loan_scheme, style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(child: CustomTableWidget(items)),
            ],
          ),
        )
      ])),
      if (itemsVault.length > 0) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_vault_details, style: Theme.of(context).textTheme.caption))),
      if (itemsVault.length > 0) SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: CustomTableWidget(itemsVault),
              ),
            ],
          ),
        )
      ]))
    ]);
  }

  _buildTabCollaterals() {
    if (myVault.collateralAmounts.length == 0) {
      return Column(children: [Text(S.of(context).loan_no_collateral_amounts)]);
    }

    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildCollateralEntry(myVault.collateralAmounts.elementAt(index));
          },
          childCount: myVault.collateralAmounts.length,
        ),
      )
    ]);
  }

  _buildCollateralEntry(LoanVaultAmount amount) {
    var token = _tokens.firstWhere((element) => amount.symbol == element.token.symbol, orElse: () => null);
    double price = amount.activePrice != null ? amount.activePrice.active.amount : 1.0;
    double factor = token != null ? double.tryParse(token.factor) : 1.0;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[
                TokenIcon(amount.symbol),
                Container(width: 5),
                Text(amount.displaySymbol),
                Container(width: 10),
                Chip(label: Text((factor * 100.00).toString() + '%'))
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_collateral_amount, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_vault_interest, style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(FundFormatter.format(double.tryParse(amount.amount))),
                    Text(FundFormatter.format(price * double.tryParse(amount.amount), fractions: 2) + " \$", style: Theme.of(context).textTheme.caption)
                  ]),
                  Text(LoanHelper.calculateCollateralShare(double.tryParse(myVault.collateralValue), amount, token).toStringAsFixed(2) + '%')
                ]),
              ])
            ])));
  }

  // _buildTabAuctions() {
  //   return Container(
  //     child: ListView.builder(
  //       physics: const ClampingScrollPhysics(),
  //       itemCount: 1,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Text('disabled');
  //       },
  //     ),
  //   );
  // }

  Widget _buildTopPart() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      VaultStatusWidget(myVault.healthStatus),
                      Row(
                        children: [
                          IconButton(
                              onPressed: !_canEditCollateral ? null : () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultEditSchemeScreen(myVault)));
                                await refreshVault();
                              },
                              icon: Icon(Icons.edit)),
                          SizedBox(width: 10),
                          IconButton(
                              onPressed: !_canEditCollateral ? null : () async {
                                if (myVault.loanAmounts.length > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).loan_close_vault_not_possible_due_loans)));
                                  return;
                                }

                                await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                                  await _doCloseVault();
                                });
                              },
                              icon: Icon(Icons.close))
                        ],
                      )
                    ]),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SelectableText(
                          myVault.vaultId,
                          maxLines: 4,
                          style: Theme.of(context).textTheme.subtitle2,
                        )
                      ]))
                    ]),
                    if (isDFILessThan50) Padding(padding: EdgeInsets.only(bottom: 10), child: AlertWidget(S.of(context).loan_collateral_dfi_ratio, color: Colors.red)),
                    Row(children: [Expanded(child: LoanCollateralsWidget(myVault, _tokens, myVault.collateralAmounts))]),
                    if (widget.vault.state != LoanVaultStatus.in_liquidation) Container(height: 5),
                    if (widget.vault.state != LoanVaultStatus.in_liquidation) Table(border: TableBorder(), children: [
                      TableRow(children: [
                        Text(S.of(context).loan_active_loans, style: Theme.of(context).textTheme.caption),
                        Text(S.of(context).loan_total_loan_amount, style: Theme.of(context).textTheme.caption)
                      ]),
                      TableRow(children: [
                        myVault.loanAmounts.length > 0
                            ? Container(padding: new EdgeInsets.only(left: 5), child: TokenSetIcons(myVault.loanAmounts, 3))
                            : Text(S.of(context).loan_no_active_loans),
                        Text(FundFormatter.format(double.tryParse(myVault.loanValue), fractions: 2) + ' \$')
                      ]),
                    ]),
                    if (widget.vault.state != LoanVaultStatus.in_liquidation) Container(height: 10),
                    if (widget.vault.state != LoanVaultStatus.in_liquidation) Table(border: TableBorder(), children: [
                      TableRow(children: [
                        Text(S.of(context).loan_collateral_amount, style: Theme.of(context).textTheme.caption),
                        Text(S.of(context).loan_collateral_ratio, style: Theme.of(context).textTheme.caption)
                      ]),
                      TableRow(children: [Text(FundFormatter.format(double.tryParse(myVault.collateralValue), fractions: 2) + ' \$'), Text(myVault.collateralRatio + ' %')]),
                    ]),
                    if (widget.vault.state != LoanVaultStatus.in_liquidation) Container(height: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(S.of(context).loan_change_collateral),
                            onPressed: _canEditCollateral
                                ? () async {
                                    await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultAddCollateral(myVault, _tokens)));
                                    await refreshVault();
                                  }
                                : null,
                          )),
                      SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(S.of(context).loan_borrow),
                            onPressed: widget.vault.state != LoanVaultStatus.in_liquidation ? () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultBorrowLoan(loanVault: myVault)));
                              await refreshVault();
                            } : null,
                          ))
                    ])
                  ])))
        ]));
  }

  @override
  Widget build(Object context) {
    var actions = [
      Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () async {
              await refreshVault();
            },
            child: Icon(Icons.refresh, size: 26.0, color: Theme.of(context).appBarTheme.actionsIconTheme.color),
          )),
    ];
    if (_loading || _tokens == null || _loanTokens == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).loan_vault_details),
            actions: actions,
            actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
          ),
          body: LoadingWidget(text: S.of(context).loading));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).loan_vault_details),
          actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
          actions: actions,
        ),
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(child: _buildTopPart()),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: StateContainer.of(context).curTheme.primary,
                    labelColor: StateContainer.of(context).curTheme.darkColor,
                    tabs: buildChildsTabs(),
                  ),
                ),
              ];
            },
            body: PrimaryScrollController(
              controller: new ScrollController(),
              child: Container(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: TabBarView(
                      controller: _tabController,
                      children: buildChilds(),
                    )),
              ),
            )));
  }
}
