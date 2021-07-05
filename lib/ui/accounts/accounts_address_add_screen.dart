import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';

class AccountsAddressAddScreen extends StatefulWidget {
  final WalletAccount walletAccount;
  final bool isNewAddress;

  final WalletAddress walletAddress;

  AccountsAddressAddScreen(this.walletAccount, this.isNewAddress, {this.walletAddress});

  @override
  State<StatefulWidget> createState() => _AccountsAddressAddScreen();
}

class _AccountsAddressAddScreen extends State<AccountsAddressAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  AddressType _addressType = AddressType.P2SHSegwit;
  bool _isExpanded = false;

  _init() {
    if (!widget.isNewAddress) {
      _nameController.text = widget.walletAddress.name;
    }
  }

  @override
  initState() {
    super.initState();

    _init();
  }

  _buildAccountAddressAddScreen(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                  child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: S.of(context).label,
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).wallet_accounts_cannot_be_empty;
                  }
                  return null;
                },
              )),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpansionPanelList(
                      expandedHeaderPadding: EdgeInsets.all(5),
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                            headerBuilder: (context, isOpen) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  S.of(context).advanced,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                            body: Column(
                              children: <Widget>[
                                ListTile(
                                  title: const Text('Default'),
                                  leading: Radio<AddressType>(
                                    value: AddressType.P2SHSegwit,
                                    groupValue: _addressType,
                                    onChanged: (AddressType value) {
                                      setState(() {
                                        _addressType = value;
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
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            isExpanded: _isExpanded)
                      ])),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      final walletService = sl.get<IWalletService>();

                      WalletAddress walletAddress;
                      if (widget.isNewAddress) {
                        walletAddress = await walletService.getNextWalletAddress(widget.walletAccount.chain, false, _addressType);
                        walletAddress.createdAt = DateTime.now();
                      } else {
                        walletAddress = widget.walletAddress;
                      }

                      walletAddress.name = _nameController.text;

                      await walletService.updateAddress(walletAddress);

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(widget.isNewAddress ? S.of(context).add : S.of(context).save),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(S.of(context).wallet_accounts_add),
          actions: [],
        ),
        body: _buildAccountAddressAddScreen(context));
  }
}
