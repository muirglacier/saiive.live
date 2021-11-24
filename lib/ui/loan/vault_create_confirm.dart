import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:flutter/material.dart';
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

class VaultCreateConfirmScreen extends StatefulWidget {
  final LoanSchema schema;

  VaultCreateConfirmScreen(this.schema);

  @override
  State<StatefulWidget> createState() {
    return _VaultCreateConfirmScreen();
  }
}

class _VaultCreateConfirmScreen extends State<VaultCreateConfirmScreen> {
  String _toAddress;
  String _returnAddress;

  int _vaultFees = 200000000;

  void getVaultCreateFees() async {
    var chainNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();

    if (chainNet == ChainNet.Testnet) {
      setState(() {
        _vaultFees = 100000000;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getVaultCreateFees();
  }

  Future doCreateVault() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    final walletTo = _toAddress;
    try {
      var streamController = StreamController<String>();
      var createVault = wallet.createVault(widget.schema.id, _vaultFees, returnAddress: _returnAddress, ownerAddress: walletTo, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createVault);

      streamController.close();

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, S.of(context).loan_create_vault_success),
      ));

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      Wakelock.disable();
    }
  }

  _buildView() {
    List<List<String>> items = [
      [S.of(context).loan_transaction_type, S.of(context).loan_create_vault],
      [S.of(context).loan_create_vault_fee, FundFormatter.format(_vaultFees / 100000000)],
      [S.of(context).loan_create_est_fee, FundFormatter.format(0.0002)],
      [S.of(context).loan_create_fees, FundFormatter.format(_vaultFees / 100000000 + 0.0002)],
    ];

    List<List<String>> itemsSchema = [
      [S.of(context).loan_min_collateral_ratio, widget.schema.minColRatio],
      [S.of(context).loan_vault_interest_rate_apr, widget.schema.interestRate],
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(S.of(context).loan_create_vault_info, style: Theme.of(context).textTheme.headline6),
                    Row(children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          S.of(context).loan_create_id_generated,
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
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(S.of(context).loan_vault_details, style: Theme.of(context).textTheme.caption))),
      SliverList(
          delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: CustomTableWidget(itemsSchema),
              )
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
                    checkBoxText: S.of(context).loan_vault_customer_owner_address,
                    title: S.of(context).loan_vault_owner_address,
                    onChanged: (v) {
                      setState(() {
                        _toAddress = v;
                      });
                    },
                  )),
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
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Column(children: [
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text(S.of(context).loan_continue),
                        onPressed: () async {
                          await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                            await doCreateVault();
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
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_confirm_create_vault)), body: _buildView());
  }
}
