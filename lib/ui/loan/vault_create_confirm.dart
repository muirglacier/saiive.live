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
      var createVault = wallet.createVault(widget.schema.id, _vaultFees, ownerAddress: walletTo, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createVault);

      streamController.close();

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, "Create vault successfull!"),
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
      ['Transaction Type', 'Create vault'],
      ['Vault fee', FundFormatter.format(_vaultFees / 100000000)],
      ['Estimated Fee', FundFormatter.format(0.0002)],
      ['Total transaction cost', FundFormatter.format(_vaultFees / 100000000 + 0.0002)],
    ];

    List<List<String>> itemsSchema = [
      ['Min. collateral ratio', widget.schema.minColRatio],
      ['Interest rate (APR)', widget.schema.interestRate],
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('You are creating a vault', style: Theme.of(context).textTheme.headline6),
                    Row(children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'ID will be generated once the vault has been created',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.caption,
                        )
                      ]))
                    ])
                  ])))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Transaction Details', style: Theme.of(context).textTheme.caption))),
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
                    itemCount: itemsSchema.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = itemsSchema[index];

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
              Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 10),
                  child: WalletReturnAddressWidget(
                    checkBoxText: "Use custom vault owner address",
                    onChanged: (v) {
                      setState(() {
                        _toAddress = v;
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
                        child: Text('Continue'),
                        onPressed: () async {
                          await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                            await doCreateVault();
                          });
                        })),
                SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }))
              ])))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Confirm Create Vault')), body: _buildView());
  }
}
