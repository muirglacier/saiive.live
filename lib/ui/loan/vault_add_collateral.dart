import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/collateral/vault_add_collateral.dart';
import 'package:saiive.live/ui/loan/collateral/vault_edit_collateral.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/Navigated.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

class VaultAddCollateral extends StatefulWidget {
  final LoanVault vault;
  final key = GlobalKey();

  VaultAddCollateral(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateral();
  }
}

class _VaultAddCollateral extends State<VaultAddCollateral> {
  PanelController _panelController = PanelController();
  Map<String, double> changes = Map();
  List<LoanVaultAmount> _collateralAmounts;
  Widget _panel = Container();
  List<AccountBalance> _accountBalance;

  @override
  void initState() {
    super.initState();

    _loadBalance();

    setState(() {
      _collateralAmounts = List.from(widget.vault.collateralAmounts);
    });
  }

  _loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    var filteredBalance = accountBalance.where((element) => element.isDAT && !element.isLPS).toList();

    setState(() {
      _accountBalance = filteredBalance;
    });
  }

  Widget _buildAddCollateralPanel() {
    return Navigated(child: VaultAddCollateralTokenScreen(this._accountBalance, this.changes, (token, amount) => this.handleChangeAddCollateral(token, amount)));
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
                  child: Column(children: [
                    Row(children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

  handleRemoveCollateral(LoanVaultAmount loanAmount) {
    var existing = this.changes.keys.firstWhere((element) => element == loanAmount.symbolKey, orElse: () => null);
    var existingCollateral = _collateralAmounts.firstWhere((element) => element.symbolKey == loanAmount.symbolKey, orElse: () => null);

    if (existing != null) {
      this.changes.remove(loanAmount.symbolKey);
    }

    if (existingCollateral != null) {
      setState(() {
        this._collateralAmounts.remove(loanAmount);
      });
    }
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

    this._panelController.close();
  }

  handleChangeAddCollateral(AccountBalance balance, double amount) {
    var existing = this.changes.keys.firstWhere((element) => element == balance.token, orElse: () => null);

    if (existing != null) {
      this.changes[balance.token] += amount;
    } else {
      this.changes[balance.token] = amount;
    }

    var existingCollateral = _collateralAmounts.firstWhere((element) => element.symbolKey == balance.token, orElse: () => null);

    if (existingCollateral != null) {
      var existingAmount = double.tryParse(existingCollateral.amount);
      existingAmount += amount;

      setState(() {
        existingCollateral.amount = existingAmount.toString();
      });
    } else {
      var collateral = new LoanVaultAmount(id: "0", amount: amount.toString(), symbol: balance.token, symbolKey: balance.token, displaySymbol: balance.token, name: balance.token);

      setState(() {
        _collateralAmounts.add(collateral);
      });
    }

    setState(() {
      _panel = Container();
    });

    this._panelController.close();
  }

  Future doAddCollaterals() async {
    var streamController = StreamController<String>();
    Wakelock.enable();
    try {
      var lastTxId;
      for (var collateral in changes.keys) {
        lastTxId = await doAddCollateral(collateral, (changes[collateral] * 100000000).round(), loadingStream: streamController);

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      if (lastTxId != null) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, lastTxId, "Add collateral successfull!"),
        ));
      }
    } catch (e) {
      // ignore
    } finally {
      Wakelock.disable();
      streamController.close();
    }
  }

  Future<String> doAddCollateral(String token, int amount, {StreamController<String> loadingStream}) async {
    final wallet = sl.get<DeFiChainWallet>();

    try {
      var depositToVault = wallet.depositToVault(widget.vault.vaultId, widget.vault.ownerAddress, token, amount, loadingStream: loadingStream);

      final overlay = LoadingOverlay.of(context, loadingText: loadingStream.stream);
      var tx = await overlay.during(depositToVault);

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      return tx;
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
      throw e;
    }
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
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Row(children: <Widget>[
                TokenIcon(amount.symbol),
                Container(width: 5),
                Text(amount.displaySymbol),
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
                TableRow(children: [Text('Collateral Amount', style: Theme.of(context).textTheme.caption), Text('Vault %', style: Theme.of(context).textTheme.caption)]),
                TableRow(children: [Text(amount.amount), Text('?')]),
              ])
            ])));
  }

  @override
  Widget build(BuildContext context) {
    if (_accountBalance == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    GlobalKey<NavigatorState> key = GlobalKey();

    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Add Collateral')),
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
              _collateralAmounts.length > 0
                  ? SliverPadding(padding: EdgeInsets.only(left: 10, right: 10), sliver: _buildTabCollaterals())
                  : SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(left: 10, right: 10), child: Text('No Collateral added so far'))),
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
                                    "Add token as collateral",
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
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                child: Text('Continue'),
                                onPressed: () async {
                                  await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                                    await doAddCollaterals();
                                  });
                                }))
                      ])))
            ],
          )),
    );
  }
}
