import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:wakelock/wakelock.dart';

class VaultAddCollateralConfirmScreen extends StatefulWidget {
  final LoanVault vault;
  final List<LoanCollateral> collateralTokens;
  final List<LoanVaultAmount> currentAmounts;
  final List<LoanVaultAmount> newAmounts;
  final double originalCollateralValue;
  final double collateralValue;
  final Map<String, double> changes;
  final String returnAddress;

  final CurrencyEnum currency;
  final double tetherPrice;

  VaultAddCollateralConfirmScreen(this.vault, this.collateralTokens, this.currentAmounts, this.newAmounts, this.collateralValue, this.originalCollateralValue, this.changes,
      this.returnAddress, this.currency, this.tetherPrice);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateralConfirmScreen();
  }
}

class _VaultAddCollateralConfirmScreen extends State<VaultAddCollateralConfirmScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildTopPart() {
    return Column(children: [
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
    ]);
  }

  Future doAddCollaterals() async {
    var streamController = StreamController<String>();
    Wakelock.enable();
    try {
      var lastTxId;
      for (var collateral in widget.changes.keys) {
        lastTxId = await doUpdateCollateral(collateral, (widget.changes[collateral] * 100000000).round(), loadingStream: streamController);
      }
      if (lastTxId != null) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, lastTxId, S.of(context).loan_collateral_success),
        ));
      }
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      // ignore
    } finally {
      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      EventTaxiImpl.singleton().fire(VaultSyncStartEvent());

      Wakelock.disable();
      streamController.close();
    }
  }

  Future<String> doUpdateCollateral(String token, int amount, {StreamController<String> loadingStream}) async {
    final wallet = sl.get<DeFiChainWallet>();

    try {
      Future<String> doBlockchainMagic;

      if (amount > 0) {
        doBlockchainMagic =
            wallet.depositToVault(widget.vault.vaultId, widget.vault.ownerAddress, token, amount, returnAddress: widget.returnAddress, loadingStream: loadingStream);
      } else {
        doBlockchainMagic =
            wallet.withdrawFromVault(widget.vault.vaultId, widget.vault.ownerAddress, token, amount * -1, returnAddress: widget.returnAddress, loadingStream: loadingStream);
      }

      final overlay = LoadingOverlay.of(context, loadingText: loadingStream.stream);
      var tx = await overlay.during(doBlockchainMagic);

      return tx;
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
      throw e;
    }
  }

  _buildCollateralEntry(LoanVaultAmount amount, double collateralValue) {
    var token = widget.collateralTokens.firstWhere((element) => amount.symbol == element.token.symbol, orElse: () => null);
    double price = amount.activePrice != null ? amount.activePrice.active.amount : 1.0;
    double factor = token != null ? double.tryParse(token.factor) : 1.0;

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
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_collateral_amount, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_vault + ' %', style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [Text(amount.amount), Text(LoanHelper.calculateCollateralShare(collateralValue, amount, token).toStringAsFixed(2) + '%')]),
                TableRow(children: [
                  Text(FundFormatter.format(price * double.tryParse(amount.amount) * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency)),
                  Text('')
                ]),
              ])
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_add_collateral_confirm_title)),
        body: PrimaryScrollController(
            controller: new ScrollController(),
            child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _buildTopPart()),
                  SliverToBoxAdapter(
                      child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_current_collateral, style: Theme.of(context).textTheme.caption))),
                  if (widget.currentAmounts.length == 0)
                    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 10.0, bottom: 10), child: Text(S.of(context).loan_no_collaterals))),
                  if (widget.currentAmounts.length > 0)
                    SliverList(
                        delegate: SliverChildListDelegate([
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: widget.currentAmounts.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final item = widget.currentAmounts[index];

                                    return _buildCollateralEntry(item, widget.originalCollateralValue);
                                  }),
                            ),
                          ],
                        ),
                      )
                    ])),
                  SliverToBoxAdapter(
                      child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_collateral_changes, style: Theme.of(context).textTheme.caption))),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.changes.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final key = widget.changes.keys.elementAt(index);
                                  final amount = widget.changes.values.elementAt(index);

                                  return Card(
                                    child: ListTile(
                                      title: Text(key),
                                      subtitle: Text((amount > 0 ? "+" : '') + FundFormatter.format(amount)),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    )
                  ])),
                  SliverToBoxAdapter(
                      child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_collateral_after_tx, style: Theme.of(context).textTheme.caption))),
                  if (widget.newAmounts.length == 0) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 10.0), child: Text(S.of(context).loan_no_collaterals))),
                  if (widget.newAmounts.length > 0)
                    SliverList(
                        delegate: SliverChildListDelegate([
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: widget.newAmounts.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final item = widget.newAmounts[index];

                                      return _buildCollateralEntry(item, widget.collateralValue);
                                    })),
                          ],
                        ),
                      )
                    ])),
                  SliverToBoxAdapter(
                      child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              child: Text(S.of(context).loan_continue),
                              onPressed: () async {
                                await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                                  await doAddCollaterals();
                                });
                              }))),
                  SliverToBoxAdapter(child: Container(height: 40)),
                ]))));
  }
}
