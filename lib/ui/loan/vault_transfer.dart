import 'dart:async';
import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/addressbook/addressbook_screen.dart';
import 'package:saiive.live/ui/utils/qr_code_scan.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VaultTransferScreen extends StatefulWidget {
  final LoanVault vault;

  VaultTransferScreen(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultTransferScreen();
  }
}

class _VaultTransferScreen extends State<VaultTransferScreen> {
  var _addressController;

  Future transferVault(StreamController<String> stream) async {

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
                  width: 250,
                  child: ElevatedButton(
                    child: Text(S.of(context).wallet_send),
                    style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary),
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        final streamController = new StreamController<String>();
                        final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);

                        //overlay.during(transferVault(streamController));
                      });
                    },
                  ))
            ])));
  }
}
