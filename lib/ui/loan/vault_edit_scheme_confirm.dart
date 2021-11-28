import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:wakelock/wakelock.dart';

class VaultEditSchemeConfirmScreen extends StatefulWidget {
  final LoanVault vault;
  final LoanSchema schema;

  VaultEditSchemeConfirmScreen(this.vault, this.schema);

  @override
  State<StatefulWidget> createState() {
    return _VaultEditSchemeConfirmScreen();
  }
}

class _VaultEditSchemeConfirmScreen extends State<VaultEditSchemeConfirmScreen> {
  String _returnAddress;

  @override
  void initState() {
    super.initState();
  }

  _doUpdateVault() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();
    var streamController = StreamController<String>();

    try {
      var closeVault = wallet.updateVault(widget.vault.vaultId, widget.schema.id, widget.vault.ownerAddress, returnAddress: _returnAddress, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(closeVault);

      EventTaxiImpl.singleton().fire(VaultSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, S.of(context).loan_update_vault_success),
      ));

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      streamController.close();
      Wakelock.disable();
    }
  }

  _buildView() {
    List<List<String>> items = [
      [S.of(context).loan_transaction_type, S.of(context).loan_edit_scheme],
      [S.of(context).loan_prev_min_collateral_ratio, widget.vault.schema.minColRatio + '%'],
      [S.of(context).loan_prev_vault_interest, widget.vault.schema.interestRate + '%'],
      [S.of(context).loan_new_min_collateral_ratio, widget.schema.minColRatio + '%'],
      [S.of(context).loan_new_vault_interest, widget.schema.interestRate + '%'],
      [S.of(context).loan_edit_est_fee, FundFormatter.format(0.0002)],
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(S.of(context).loan_edit_vault_info, style: Theme.of(context).textTheme.headline6),
                    Row(children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          widget.vault.vaultId,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.caption,
                        )
                      ]))
                    ])
                  ])))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_transaction_type, style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: CustomTableWidget(items),
              ),
            ],
          ),
        )
      ])),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).expert, style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 10),
                  child: WalletReturnAddressWidget(
                    title: S.of(context).loan_return_address,
                    onChanged: (v) {
                      setState(() {
                        _returnAddress = v;
                      });
                    },
                  )),
            ],
          ),
        )
      ])),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: Column(children: [
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text(S.of(context).loan_continue),
                        onPressed: () async {
                          await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                            await _doUpdateVault();
                          });
                        })),
                SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        child: Text(S.of(context).loan_cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }))
              ])))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_confirm_edit_vault)), body: _buildView());
  }
}
