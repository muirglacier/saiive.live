import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/loan/collateral/vault_add_collateral.dart';
import 'package:saiive.live/ui/loan/collateral/vault_edit_collateral.dart';
import 'package:saiive.live/ui/loan/vault_add_collateral_confirm.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/Navigated.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// ignore: must_be_immutable
class VaultAddCollateral extends StatefulWidget {
  final LoanVault vault;
  final List<LoanCollateral> collateralTokens;
  final key = GlobalKey();

  List<LoanVaultAmount> _collateralAmounts;

  VaultAddCollateral(this.vault, this.collateralTokens) {
    this._collateralAmounts = vault.collateralAmounts
        .map((e) => LoanVaultAmount(id: e.id, amount: e.amount, symbol: e.symbol, symbolKey: e.symbolKey, name: e.name, displaySymbol: e.displaySymbol, activePrice: e.activePrice))
        .toList();
  }

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateral();
  }
}

class _VaultAddCollateral extends State<VaultAddCollateral> {
  PanelController _panelController = PanelController();
  Map<String, double> changes = Map();
  Widget _panel = Container();
  List<AccountBalance> _accountBalance;
  double _collateralValue;
  bool isDFILessThan50 = false;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    _collateralValue = double.tryParse(widget.vault.collateralValue);

    _loadBalance();
  }

  _calculateDFIPercentage() {
    var amount = widget.vault.collateralAmounts.firstWhere((element) => element.symbol == 'DFI', orElse: () => null);
    var token = widget.collateralTokens.firstWhere((element) => element.token.symbol == 'DFI', orElse: () => null);
    var percentage = 0.0;

    var totalDFI = 0.0;

    if (amount != null) {
      totalDFI += double.tryParse(amount.amount);
    }

    if (changes.containsKey('DFI')) {
      totalDFI += changes['DFI'];
    }

    if (null == amount && token != null) {
      amount = LoanVaultAmount(id: '0', amount: totalDFI.toString(), symbol: 'DFI', symbolKey: 'DFI', activePrice: token.activePrice);
    }


    if (null != amount && null != token) {
      percentage = LoanHelper.calculateCollateralShare(_collateralValue, amount, token);
    }

    setState(() {
      isDFILessThan50 = percentage < 50.0;
    });
  }

  _loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    var filteredBalance = accountBalance.where((element) => element.chain == ChainType.DeFiChain).toList();

    setState(() {
      _accountBalance = filteredBalance;
    });
  }

  Widget _buildAddCollateralPanel() {
    return Navigated(
        child: VaultAddCollateralTokenScreen(this._accountBalance, widget.collateralTokens, this.changes, (token, amount) => this.handleChangeAddCollateral(token, amount)));
  }

  Widget _buildChangeCollateralPanel(LoanVaultAmount amount) {
    var balance = _accountBalance.firstWhere((element) => element.token == amount.symbolKey, orElse: () => null);

    return Navigated(child: VaultEditCollateralTokenScreen(amount, balance, (loanAmount, amount) => this.handleChangeEditCollateral(loanAmount, amount)));
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
                            widget.vault.vaultId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(S.of(context).loan_collateral_value),
                          Text(FundFormatter.format(_collateralValue, fractions: 2) + ' \$')
                        ])),
                      ],
                    ),
                  ])))
        ]));
  }

  handleRemoveCollateral(LoanVaultAmount loanAmount) {
    var existing = this.changes.keys.firstWhere((element) => element == loanAmount.symbolKey, orElse: () => null);
    var existingCollateral = widget._collateralAmounts.firstWhere((element) => element.symbolKey == loanAmount.symbolKey, orElse: () => null);

    if (existing != null) {
      this.changes.remove(loanAmount.symbolKey);
    } else {
      this.changes[loanAmount.symbolKey] = -1 * double.tryParse(loanAmount.amount);
    }

    if (existingCollateral != null) {
      setState(() {
        widget._collateralAmounts.remove(loanAmount);
      });
    }

    _recalculateValue();
  }

  handleChangeEditCollateral(LoanVaultAmount loanAmount, double newAmount) {
    var totalLoanAmountWithChanges = double.tryParse(loanAmount.amount);
    var diff = newAmount - totalLoanAmountWithChanges;
    var existing = this.changes.keys.firstWhere((element) => element == loanAmount.symbolKey, orElse: () => null);

    if (existing != null) {
      if (-1 * diff >= changes[existing]) {
        changes.remove(loanAmount.symbolKey);
      } else {
        changes[loanAmount.symbolKey] += diff;
      }
    } else {
      changes[loanAmount.symbolKey] = diff;
    }

    newAmount = double.tryParse(loanAmount.amount) + diff;

    setState(() {
      loanAmount.amount = newAmount.toString();
      _panel = Container();
    });
    _recalculateValue();

    this._panelController.close();
  }

  handleChangeAddCollateral(LoanCollateral collateralToken, double amount) {
    var existing = this.changes.keys.firstWhere((element) => element == collateralToken.token.symbol, orElse: () => null);

    if (existing != null) {
      this.changes[collateralToken.token.symbol] += amount;
    } else {
      this.changes[collateralToken.token.symbol] = amount;
    }

    var existingCollateral = widget._collateralAmounts.firstWhere((element) => element.symbolKey == collateralToken.token.symbol, orElse: () => null);

    if (existingCollateral != null) {
      var existingAmount = double.tryParse(existingCollateral.amount);
      existingAmount += amount;

      setState(() {
        existingCollateral.amount = existingAmount.toString();
      });
    } else {
      var collateral = new LoanVaultAmount(
          id: collateralToken.tokenId,
          amount: amount.toString(),
          symbol: collateralToken.token.symbol,
          symbolKey: collateralToken.token.symbol,
          displaySymbol: collateralToken.token.symbol,
          name: collateralToken.token.symbol,
          activePrice: collateralToken.activePrice);

      setState(() {
        widget._collateralAmounts.add(collateral);
      });
    }

    _recalculateValue();

    setState(() {
      _panel = Container();
    });

    this._panelController.close();
  }

  _recalculateValue() {
    var val = 0.0;

    widget._collateralAmounts.forEach((e) {
      var priceValue = e.activePrice != null ? e.activePrice.active.amount : 0;

      val += priceValue * double.tryParse(e.amount);
    });

    setState(() {
      _collateralValue = val;
    });

    _calculateDFIPercentage();
  }

  _buildTabCollaterals() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildCollateralEntry(widget._collateralAmounts.elementAt(index));
        },
        childCount: widget._collateralAmounts.length,
      ),
    );
  }

  _buildCollateralEntry(LoanVaultAmount amount) {
    var token = widget.collateralTokens.firstWhere((element) => amount.symbol == element.token.symbol, orElse: () => null);
    double price = amount.activePrice != null ? amount.activePrice.active.amount : 0;
    double factor = token != null ? double.tryParse(token.factor) : 0;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Row(children: <Widget>[
                TokenIcon(amount.symbol),
                Container(width: 5),
                Text(amount.displaySymbol),
                Container(width: 10),
                Chip(label: Text((factor * 100.00).toString() + '%')),
                Spacer(),
                TextButton(
                    child: Icon(Icons.remove_circle_outline_outlined),
                    onPressed: () {
                      this.handleRemoveCollateral(amount);
                    }),
                Container(width: 5),
                TextButton(
                    child: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _panel = this._buildChangeCollateralPanel(amount);
                      });

                      _panelController.show();
                      _panelController.open();
                    })
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [Text(S.of(context).loan_collateral_amount, style: Theme.of(context).textTheme.caption), Text(S.of(context).loan_vault + ' %', style: Theme.of(context).textTheme.caption)]),
                TableRow(children: [Text(amount.amount), Text(LoanHelper.calculateCollateralShare(_collateralValue, amount, token).toStringAsFixed(2) + '%')]),
                TableRow(children: [Text(FundFormatter.format(price * double.tryParse(amount.amount), fractions: 2) + ' \$'), Text('')]),
              ])
            ])));
  }

  @override
  Widget build(BuildContext context) {
    if (_accountBalance == null) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_add_collateral_title)), body: LoadingWidget(text: S.of(context).loading));
    }

    GlobalKey<NavigatorState> key = GlobalKey();

    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_add_collateral_title)),
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
              if (isDFILessThan50)
                SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(10), child: AlertWidget(S.of(context).loan_collateral_dfi_ratio, color: Colors.red))),
              widget._collateralAmounts.length > 0
                  ? SliverPadding(padding: EdgeInsets.only(left: 10, right: 10), sliver: _buildTabCollaterals())
                  : SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(left: 10, right: 10), child: Text(S.of(context).loan_no_collateral_amounts))),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Column(children: [
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Icon(Icons.add, color: StateContainer.of(context).curTheme.text),
                                  SizedBox(width: 10),
                                  Text(
                                    S.of(context).loan_add_token_as_collateral,
                                    style: TextStyle(color: StateContainer.of(context).curTheme.text),
                                  ),
                                ]),
                                onPressed: () {
                                  setState(() {
                                    _panel = this._buildAddCollateralPanel();
                                  });

                                  _panelController.show();
                                  _panelController.open();
                                })),
                        Container(height: 10),
                        Padding(
                            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
                            child: WalletReturnAddressWidget(
                              onChanged: (v) {
                                setState(() {
                                  _returnAddress = v;
                                });
                              },
                            )),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                child: Text(S.of(context).loan_continue),
                                onPressed: changes.length > 0
                                    ? () async {
                                        await Navigator.of(context).push(MaterialPageRoute(
                                            builder: (BuildContext context) => VaultAddCollateralConfirmScreen(widget.vault, widget.collateralTokens,
                                                widget.vault.collateralAmounts, widget._collateralAmounts, _collateralValue, changes, _returnAddress)));
                                      }
                                    : null))
                      ])))
            ],
          )),
    );
  }
}
