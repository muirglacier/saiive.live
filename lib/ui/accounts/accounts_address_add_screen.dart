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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: S.of(context).label),
          ),
          if (widget.isNewAddress)
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 5, left: 5, right: 5),
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
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (_nameController.text != null && _nameController.text.isNotEmpty) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          title: Text(widget.isNewAddress ? S.of(context).wallet_accounts_add : S.of(context).wallet_accounts_edit),
          actions: [],
        ),
        body: _buildAccountAddressAddScreen(context));
  }
}
