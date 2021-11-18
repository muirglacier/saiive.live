import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:wakelock/wakelock.dart';

class VaultAddCollateralConfirmScreen extends StatefulWidget {
  LoanVault vault;
  List<LoanVaultAmount> currentAmounts;
  List<LoanVaultAmount> newAmounts;
  Map<String, double> changes;

  VaultAddCollateralConfirmScreen(this.vault, this.currentAmounts, this.newAmounts, this.changes);

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
          builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, lastTxId, "Add collateral successfull!"),
        ));
      }
      Navigator.of(context).pop();
    } catch (e) {
      // ignore
    } finally {
      Wakelock.disable();
      streamController.close();
    }
  }

  Future<String> doUpdateCollateral(String token, int amount, {StreamController<String> loadingStream}) async {
    final wallet = sl.get<DeFiChainWallet>();

    try {
      Future<String> doBlockchainMagic;
      if (amount > 0) {
        doBlockchainMagic = wallet.depositToVault(widget.vault.vaultId, widget.vault.ownerAddress, token, amount, loadingStream: loadingStream);
      } else {
        doBlockchainMagic = wallet.withdrawFromVault(widget.vault.vaultId, widget.vault.ownerAddress, token, amount * -1, loadingStream: loadingStream);
      }

      final overlay = LoadingOverlay.of(context, loadingText: loadingStream.stream);
      var tx = await overlay.during(doBlockchainMagic);

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      return tx;
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Add Collateral Confirm')),
      body: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0), child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(child: _buildTopPart()),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Current Collaterals', style: Theme.of(context).textTheme.caption))),
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

                                return Card(
                                      child: ListTile(
                                        title: Text(item.displaySymbol),
                                        subtitle: Text(FundFormatter.format(double.tryParse(item.amount))),
                                      ),
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                ])),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Changes', style: Theme.of(context).textTheme.caption))),
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
                                        subtitle: Text(FundFormatter.format(amount)),
                                      ),
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                ])),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Final Collateral after TX', style: Theme.of(context).textTheme.caption))),
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

                                  return Card(
                                        child: ListTile(
                                          title: Text(item.displaySymbol),
                                          subtitle: Text(item.amount),
                                        ),
                                  );
                                })
                        ),
                      ],
                    ),
                  )
                ])),
            SliverToBoxAdapter(
                child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            child: Text('Continue'),
                            onPressed: () async {
                              await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                                await doAddCollaterals();
                              });
                            })))
      ]))
    );
  }
}
