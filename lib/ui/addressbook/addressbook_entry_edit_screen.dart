import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/addressbook/address_book_db.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/model/address_book_model.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/qr_code_scan.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:uuid/uuid.dart';

class AddressBookEntryEditScreen extends StatefulWidget {
  final ChainType chainType;
  final AddressBookEntry addressBookEntry;
  final bool isNewEntry;
  final IAddressBookDatabase database;

  AddressBookEntryEditScreen(this.chainType, this.addressBookEntry, this.isNewEntry, this.database);

  @override
  State<StatefulWidget> createState() => _AddressBookEntryEditScreen();
}

class _AddressBookEntryEditScreen extends State<AddressBookEntryEditScreen> {
  final _nameController = TextEditingController();
  final _pubKeyController = TextEditingController();

  @override
  initState() {
    super.initState();

    if (!widget.isNewEntry) {
      _nameController.text = widget.addressBookEntry.name;
      _pubKeyController.text = widget.addressBookEntry.publicKey;
    }
  }

  _buildEditScreen(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: S.of(context).label),
          ),
          TextField(
              controller: _pubKeyController,
              decoration: (Platform.isMacOS || Platform.isWindows)
                  ? InputDecoration(hintText: S.of(context).wallet_send_address)
                  : InputDecoration(
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
                                  _pubKeyController.text = address;
                                },
                                icon: Icon(Icons.camera_alt, color: StateContainer.of(context).curTheme.primary),
                              )
                          ]))),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text != null && _nameController.text.isNotEmpty && _pubKeyController.text != null && _pubKeyController.text.isNotEmpty) {
                  final currentNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
                  var address = widget.addressBookEntry;
                  var pubKey = _pubKeyController.text;

                  if (!HdWalletUtil.isAddressValid(pubKey, widget.chainType, currentNet)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).wallet_accounts_import_invalid_pub_key),
                    ));
                    return;
                  }

                  if (widget.isNewEntry) {
                    address = new AddressBookEntry(id: Uuid().v4(), publicKey: pubKey, name: _nameController.text, chain: widget.chainType);

                    await widget.database.addAddressBookEntry(address);
                  } else {
                    address.name = _nameController.text;
                    address.publicKey = pubKey;

                    await widget.database.updateAddressBookEntry(address);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.isNewEntry ? S.of(context).add : S.of(context).save),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(widget.isNewEntry ? S.of(context).addressbook_add : S.of(context).addressbook_edit),
          actions: [],
        ),
        body: _buildEditScreen(context));
  }
}
