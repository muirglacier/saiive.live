import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VaultAddCollateral extends StatefulWidget {
  final LoanVault vault;
  final key = GlobalKey();

  VaultAddCollateral(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateral();
  }
}

class VaultAddCollateralTokenScreen extends StatefulWidget {
  final Function(AccountBalance token, double amount) onCollateralChanged;

  VaultAddCollateralTokenScreen(this.onCollateralChanged);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateralTokenScreen();
  }
}

class _VaultAddCollateralTokenScreen
    extends State<VaultAddCollateralTokenScreen> {
  List<AccountBalance> _accountBalance;

  @override
  void initState() {
    super.initState();

    _loadBalance();
  }

  _loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance =
        await balanceHelper.getDisplayAccountBalance(spentable: true);

    var filteredBalance = accountBalance
        .where((element) => element.isDAT && !element.isLPS)
        .toList();

    setState(() {
      _accountBalance = filteredBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accountBalance == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(30),
        child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final account = _accountBalance.elementAt(index);
                    return _buildAccountEntry(account);
                  },
                  childCount: _accountBalance.length,
                ),
              )
            ]));
  }

  Widget _buildAccountEntry(AccountBalance balance) {
    return Card(
        child: ListTile(
      leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [TokenIcon(balance.token)]),
      title: Column(children: [
        Row(children: [
          Text(
            balance.token,
            style: Theme.of(context).textTheme.headline3,
          ),
          Expanded(
              child: AutoSizeText(
            FundFormatter.format(balance.balanceDisplay),
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.right,
            maxLines: 1,
          )),
        ])
      ]),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => VaultAddCollateralAmountScreen(
                balance,
                (amount) =>
                    {this.widget.onCollateralChanged(balance, amount)})));
      },
    ));
  }
}

class VaultAddCollateralAmountScreen extends StatefulWidget {
  final AccountBalance token;
  final Function(double amount) onCollateralChanged;

  VaultAddCollateralAmountScreen(this.token, this.onCollateralChanged);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateralAmountScreen();
  }
}

class _VaultAddCollateralAmountScreen
    extends State<VaultAddCollateralAmountScreen> {
  var _amountController = TextEditingController(text: '');
  double _amount = 0;

  @override
  void initState() {
    super.initState();

    _amountController.addListener(handleChange);
  }

  handleChange() async {
    double amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));

    setState(() {
      _amount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: StateContainer.of(context).curTheme.cardBackgroundColor,
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                              hintText: 'How much to add?',
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0)),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true)),
                      Container(height: 10),
                      Text('Available: ' +
                          FundFormatter.format(widget.token.balanceDisplay)),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(S.of(context).liquidity_add),
                            onPressed: _amount == null || _amount == 0
                                ? null
                                : () {
                                    this.widget.onCollateralChanged(_amount);
                                  },
                          ))
                    ]))));
  }
}

class _VaultAddCollateral extends State<VaultAddCollateral> {
  PanelController _panelController = PanelController();
  Map<String, double> changes = Map();
  List<LoanVaultAmount> _collateralAmounts;

  @override
  void initState() {
    super.initState();

    setState(() {
      _collateralAmounts = List.from(widget.vault.collateralAmounts);
    });
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
                      Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              widget.vault.vaultId,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ])),
                    ]),
                  ])))
        ]));
  }

  handleChangeAddCollateral(AccountBalance balance, double amount) {
    var existing = this
        .changes
        .keys
        .firstWhere((element) => element == balance.token, orElse: () => null);

    if (existing != null) {
      this.changes[balance.token] += amount;
    } else {
      this.changes[balance.token] = amount;
    }

    var existingCollateral = _collateralAmounts.firstWhere(
        (element) => element.symbolKey == balance.token,
        orElse: () => null);

    if (existingCollateral != null) {
      var existingAmount = double.tryParse(existingCollateral.amount);
      existingAmount += amount;

      setState(() {
        existingCollateral.amount = existingAmount.toString();
      });
    } else {
      var collateral = new LoanVaultAmount(
          id: "0",
          amount: amount.toString(),
          symbol: balance.token,
          symbolKey: balance.token,
          displaySymbol: balance.token,
          name: balance.token);

      setState(() {
        _collateralAmounts.add(collateral);
      });
    }

    this._panelController.close();
  }

  _buildTabCollaterals() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildCollateralEntry(_collateralAmounts.elementAt(index));
        },
        childCount: _collateralAmounts.length,
      ),
    );
  }

  _buildCollateralEntry(LoanVaultAmount amount) {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[
                TokenIcon(amount.symbol),
                Container(width: 5),
                Text(amount.displaySymbol)
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Collateral Amount',
                      style: Theme.of(context).textTheme.caption),
                  Text('Vault %', style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [Text(amount.amount), Text('?')]),
              ])
            ])));
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<NavigatorState> key = GlobalKey();
    GlobalKey<ScaffoldState> state = GlobalKey();

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text('Add Collateral')),
      body: SlidingUpPanel(
          controller: _panelController,
          backdropEnabled: true,
          defaultPanelState: PanelState.CLOSED,
          minHeight: 0,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          color: StateContainer.of(context).curTheme.cardBackgroundColor,
          onPanelClosed: () => {
                if (key != null &&
                    key.currentState != null &&
                    key.currentState.canPop())
                  {key.currentState.pop()}
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
                    decoration: BoxDecoration(
                        color:
                            StateContainer.of(context).curTheme.backgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              Expanded(
                  child: Scaffold(
                key: state,
                body: Container(
                    color:
                        StateContainer.of(context).curTheme.cardBackgroundColor,
                    child: Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          settings: settings,
                          builder: (BuildContext context) {
                            return VaultAddCollateralTokenScreen((token,
                                    amount) =>
                                this.handleChangeAddCollateral(token, amount));
                          },
                        );
                      },
                    )),
              ))
            ]);
          }),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopPart()),
              _collateralAmounts.length > 0
                  ? _buildTabCollaterals()
                  : SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text('No Collateral added so far'))),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Column(children: [
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                child: Text('Add Token as Collateral'),
                                onPressed: () {
                                  _panelController.show();
                                  _panelController.open();
                                }))
                      ])))
            ],
          )),
    );
  }
}
