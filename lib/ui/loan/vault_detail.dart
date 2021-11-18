import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_add_collateral.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/loan_collateral.dart';
import 'package:saiive.live/ui/utils/loan_collaterals.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/token_set_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class VaultDetailScreen extends StatefulWidget {
  final LoanVault vault;

  VaultDetailScreen(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultDetailScreen();
  }
}

class _VaultDetailScreen extends State<VaultDetailScreen> with SingleTickerProviderStateMixin {
  final bodyGlobalKey = GlobalKey();
  TabController _tabController;
  ScrollController _scrollController;
  bool fixedScroll;
  List <LoanCollateral> _tokens;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_smoothScrollToTop);

    _initTokens();

    super.initState();
  }

  _initTokens() async {
    setState(() {
      _tokens = null;
    });

    var tokens = await sl.get<ILoansService>().getLoanCollaterals(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _tokens = tokens;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(microseconds: 300),
      curve: Curves.ease,
    );

    setState(() {
      fixedScroll = _tabController.index == 2;
    });
  }

  _buildTabActiveLoans() {
    if (widget.vault.loanAmounts.length == 0) {
      return Container(child: Text('no loan amounts'));
    }

    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildLoanEntry(widget.vault.loanAmounts.elementAt(index));
          },
          childCount: widget.vault.loanAmounts.length,
        ),
      )
    ]);
  }

  _buildLoanEntry(LoanVaultAmount amount) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[TokenIcon(amount.symbol), Container(width: 5), Text(amount.displaySymbol)]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Borrowed Tokens', style: Theme.of(context).textTheme.caption),
                  Text('Interest amount (${widget.vault.schema.interestRate} %)', style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [Text(amount.amount), Text((double.tryParse(amount.amount) * double.tryParse(widget.vault.schema.interestRate) / 100).toString())]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [Text('Amount Payable', style: Theme.of(context).textTheme.caption), Text('Price per Token', style: Theme.of(context).textTheme.caption)]),
                TableRow(children: [Text('?'), Text('?')]),
              ]),
              Container(height: 10),
              Row(children: [
                ElevatedButton(
                  child: Text('Repay Loan'),
                  onPressed: () {
                    //TODO
                  },
                ),
                Container(width: 10),
                ElevatedButton(
                  child: Text('Borrow more'),
                  onPressed: () {
                    //TODO
                  },
                )
              ])
            ])));
  }

  _buildTabDetails() {
    List<List<String>> items = [
      ['Min. collateral ratio', widget.vault.schema.minColRatio],
      ['Vault interest', widget.vault.schema.interestRate],
    ];

    List<List<String>> itemsVault = [
      ['Collateral ratio', widget.vault.collateralRatio],
      ['Active loans', widget.vault.loanAmounts.length.toString()],
      ['Total Value of Loans', widget.vault.loanAmounts.fold("0", (sum, next) => (double.tryParse(sum) + double.tryParse(next.amount)).toString())],
      ['Collateral Value', FundFormatter.format(double.tryParse(widget.vault.collateralValue), fractions: 2) + ' \$'],
      ['Vault health', widget.vault.healthStatus.toString()],
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Loan Scheme', style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Card(
                            child: ListTile(
                          title: Text(item.elementAt(0)),
                          subtitle: Text(item.elementAt(1)),
                        )),
                      );
                    }),
              ),
            ],
          ),
        )
      ])),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Vault Details', style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itemsVault.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = itemsVault[index];

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Card(
                            child: ListTile(
                          title: Text(item.elementAt(0)),
                          subtitle: Text(item.elementAt(1)),
                        )),
                      );
                    }),
              ),
            ],
          ),
        )
      ]))
    ]);
  }

  _buildTabCollaterals() {
    if (widget.vault.collateralAmounts.length == 0) {
      return Container(child: Text('no collateral amounts'));
    }

    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildCollateralEntry(widget.vault.collateralAmounts.elementAt(index));
          },
          childCount: widget.vault.collateralAmounts.length,
        ),
      )
    ]);
  }

  _buildCollateralEntry(LoanVaultAmount amount) {
    var token = _tokens.firstWhere((element) => amount.symbol == element.token.symbol, orElse: () => null);
    double price = amount.activePrice != null ? amount.activePrice.active.amount : 0;
    int factor = token != null ? int.tryParse(token.factor) : 0;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[TokenIcon(amount.symbol), Container(width: 5), Text(amount.displaySymbol), Container(width: 10), InputChip(label: Text((factor * 100.00).toString() + '%'))]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [Text('Collateral Amount', style: Theme.of(context).textTheme.caption), Text('Vault %', style: Theme.of(context).textTheme.caption)]),
                TableRow(children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(FundFormatter.format(double.tryParse(amount.amount))), Text(FundFormatter.format(price * double.tryParse(amount.amount), fractions: 2) + " \$", style: Theme.of(context).textTheme.caption)]), Text(LoanHelper.calculateCollateralShare(double.tryParse(widget.vault.collateralValue), amount, token).toStringAsFixed(2) + '%')]),
              ])
            ])));
  }

  _buildTabAuctions() {
    return Container(
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: 200,
        itemBuilder: (BuildContext context, int index) {
          return Text('some content');
        },
      ),
    );
  }

  Widget _buildTopPart() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(children: [
                    Row(children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SelectableText(
                          widget.vault.vaultId,
                          maxLines: 1,
                          scrollPhysics: NeverScrollableScrollPhysics(),
                          style: Theme.of(context).textTheme.headline6,
                        )
                      ])),
                      Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: InputChip(
                            label: Text(widget.vault.healthStatus.toShortString()),
                            onSelected: (bool value) {},
                          ))
                    ]),
                    Container(height: 10),
                    Row(children: [Expanded(child: LoanCollateralsWidget(widget.vault, _tokens, widget.vault.collateralAmounts))]),
                    Container(height: 10),
                    Table(border: TableBorder(), children: [
                      TableRow(children: [Text('Active Loans', style: Theme.of(context).textTheme.caption), Text('Total Loan Amount', style: Theme.of(context).textTheme.caption)]),
                      TableRow(children: [
                        Container(padding: new EdgeInsets.only(left: 5), child: TokenSetIcons(widget.vault.loanAmounts, 3)),
                        Text(widget.vault.loanAmounts.fold("0", (sum, next) => (double.tryParse(sum) + double.tryParse(next.amount)).toString()))
                      ]),
                    ]),
                    Container(height: 10),
                    Table(border: TableBorder(), children: [
                      TableRow(
                          children: [Text('Collateral Amount', style: Theme.of(context).textTheme.caption), Text('Collateral Ratio', style: Theme.of(context).textTheme.caption)]),
                      TableRow(children: [
                        Text(FundFormatter.format(double.tryParse(widget.vault.collateralValue), fractions: 2) + '\$'),
                        Text(widget.vault.collateralRatio)
                      ]),
                    ]),
                    Container(height: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text('Change Collateral'),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultAddCollateral(widget.vault, _tokens)));
                            },
                          ))
                    ])
                  ])))
        ]));
  }

  @override
  Widget build(Object context) {
    if (_tokens == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Vault Detail'),
            actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
          ),
          body: LoadingWidget(text: S.of(context).loading)
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Vault Detail'),
          actionsIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.appBarText),
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
                  tabs: [
                    Tab(text: 'Active loan'),
                    Tab(text: 'Details'),
                    Tab(text: 'Collaterals'),
                    Tab(text: 'Auctions'),
                  ],
                ),
              ),
            ];
          },
          body: Container(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildTabActiveLoans(), _buildTabDetails(), _buildTabCollaterals(), _buildTabAuctions()],
                )),
          ),
        ));
  }
}
