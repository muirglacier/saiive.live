import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';

class AccountImportPrivateKeySelectAddressTypeDialog extends StatefulWidget {
  const AccountImportPrivateKeySelectAddressTypeDialog({this.onValueChange, this.initialValue});

  final AddressType initialValue;
  final void Function(AddressType) onValueChange;

  @override
  State createState() => new _AccountImportPrivateKeySelectAddressTypeDialog();
}

class _AccountImportPrivateKeySelectAddressTypeDialog extends State<AccountImportPrivateKeySelectAddressTypeDialog> {
  AddressType _addressType;

  @override
  void initState() {
    super.initState();
    _addressType = widget.initialValue;
  }

  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text(S.of(context).wallet_accounts_select_type),
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ListTile(
                title: const Text('Default'),
                leading: Radio<AddressType>(
                  value: AddressType.P2SHSegwit,
                  groupValue: _addressType,
                  onChanged: (AddressType value) {
                    setState(() {
                      _addressType = value;
                      widget.onValueChange(value);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Legacy'),
                leading: Radio<AddressType>(
                  value: AddressType.Legacy,
                  groupValue: _addressType,
                  onChanged: (AddressType value) {
                    setState(() {
                      _addressType = value;
                      widget.onValueChange(value);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Bech32'),
                leading: Radio<AddressType>(
                  value: AddressType.Bech32,
                  groupValue: _addressType,
                  onChanged: (AddressType value) {
                    setState(() {
                      _addressType = value;
                      widget.onValueChange(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 40),
              Center(
                  child: Row(children: [
                ElevatedButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addressType = null;
                    widget.onValueChange(null);
                  },
                ),
                Spacer(),
                ElevatedButton(
                  child: Text(S.of(context).ok),
                  onPressed: () async {
                    try {} finally {
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]))
            ],
          ),
        )
      ],
    );
  }
}
