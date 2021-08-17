import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/wallet_receive.dart';

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
  bool _isDetailsExpanded = true;
  bool _isQrExpanded = false;

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
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    S.of(context).advanced,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ));
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
                              // ListTile(
                              //   title: const Text('Legacy'),
                              //   leading: Radio<AddressType>(
                              //     value: AddressType.Legacy,
                              //     groupValue: _addressType,
                              //     onChanged: (AddressType value) {
                              //       setState(() {
                              //         _addressType = value;
                              //       });
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                          isExpanded: _isExpanded)
                    ])),
          if (!widget.isNewAddress)
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 5, left: 5, right: 5),
                child: ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(5),
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _isDetailsExpanded = !_isDetailsExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                          isExpanded: _isDetailsExpanded,
                          headerBuilder: (context, isOpen) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDetailsExpanded = !_isDetailsExpanded;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    S.of(context).details,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ));
                          },
                          body: Column(children: <Widget>[
                            ListTile(
                              leading: Text(S.of(context).address + ": "),
                              title: Text(widget.walletAddress.publicKey),
                            ),
                            ListTile(
                              leading: const Text('Path' + ": "),
                              title: Text(widget.walletAddress.path(widget.walletAccount)),
                            ),
                            ListTile(
                              leading: const Text('Type' + ": "),
                              title: Text(widget.walletAddress.addressType.toString()),
                            )
                          ]))
                    ])),
          if (!widget.isNewAddress)
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 5, left: 5, right: 5),
                child: ExpansionPanelList(
                    expandedHeaderPadding: EdgeInsets.all(5),
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _isQrExpanded = !_isQrExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                          isExpanded: _isQrExpanded,
                          headerBuilder: (context, isOpen) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isQrExpanded = !_isQrExpanded;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    S.of(context).address,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ));
                          },
                          body: Column(children: <Widget>[WalletReceiveWidget(pubKey: widget.walletAddress.publicKey, chain: widget.walletAccount.chain, showOnlyQr: true)]))
                    ])),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  if (_nameController.text != null && _nameController.text.isNotEmpty) {
                    final walletService = sl.get<IWalletService>();

                    WalletAddress walletAddress;
                    if (widget.isNewAddress) {
                      walletAddress = await walletService.getNextWalletAddress(widget.walletAccount, false, _addressType);
                      walletAddress.createdAt = DateTime.now();
                    } else {
                      walletAddress = widget.walletAddress;
                    }

                    walletAddress.name = _nameController.text;

                    await walletService.updateAddress(walletAddress);

                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).wallet_offline(e.toString()))));
                  sl.get<AppCenterWrapper>().trackEvent("addAccountAddressError", <String, String>{'error': e.toString()});
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
        body: SingleChildScrollView(child: _buildAccountAddressAddScreen(context)));
  }
}