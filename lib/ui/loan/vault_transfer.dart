import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/addressbook/addressbook_screen.dart';
import 'package:saiive.live/ui/utils/qr_code_scan.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class VaultTransferScreen extends StatefulWidget {
  final LoanVault vault;

  VaultTransferScreen(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultTransferScreen();
  }
}

class _VaultTransferScreen extends State<VaultTransferScreen> {
  TextEditingController _addressController;

  Future transferVault(StreamController<String> stream) async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    final walletTo = _addressController.text;
    var streamController = StreamController<String>();
    try {
      var createVault = wallet.updateVaultOwner(widget.vault.vaultId, widget.vault.schema.id, widget.vault.ownerAddress, walletTo);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createVault);

      EventTaxiImpl.singleton().fire(VaultSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, S.of(context).loan_update_vault_success),
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

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController();
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_vault_transfer)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: TextField(
                            controller: _addressController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: S.of(context).wallet_send_address,
                                suffixIcon: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (Platform.isAndroid || Platform.isIOS)
                                        IconButton(
                                          onPressed: () async {
                                            var status = await Permission.camera.status;
                                            if (!status.isGranted) {
                                              final permission = await Permission.camera.request();

                                              if (!permission.isGranted) {
                                                return;
                                              }
                                            }
                                            final address = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => QrCodeScan()));
                                            _addressController.text = address;
                                          },
                                          icon: Icon(Icons.camera_alt, color: StateContainer.of(context).curTheme.primary),
                                        ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () async {
                                          AddressBookEntry usedAddress;
                                          await Navigator.of(context).push(MaterialPageRoute(
                                              builder: (BuildContext context) => AddressBookScreen(
                                                  selectOnlyMode: true,
                                                  chainFilter: ChainType.DeFiChain,
                                                  onAddressSelected: (a) {
                                                    usedAddress = a;
                                                  })));

                                          if (usedAddress != null) {
                                            setState(() {
                                              _addressController.text = usedAddress.publicKey;
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.import_contacts, color: StateContainer.of(context).curTheme.primary),
                                      ),
                                    ])))))
              ]),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    child: Text(S.of(context).wallet_send),
                    style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        final streamController = new StreamController<String>();
                        final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                        overlay.during(transferVault(streamController));
                      });
                    },
                  ))
            ])));
  }
}
