import 'package:flutter/material.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/accounts/account_select_address_widget.dart';

class WalletReturnAddressWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  WalletReturnAddressWidget({@required this.onChanged});

  _WalletReturnAddressWidgetState createState() => _WalletReturnAddressWidgetState();
}

class _WalletReturnAddressWidgetState extends State<WalletReturnAddressWidget> {
  var _isExpanded = false;
  var _useCustomReturnAddress = false;

  WalletAddress _toAddress;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(5),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              isExpanded: _isExpanded,
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
                        S.of(context).expert,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ));
              },
              body: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Column(children: <Widget>[
                      Row(
                        children: [
                          Text(S.of(context).wallet_use_custom_return_address),
                          Checkbox(
                            value: this._useCustomReturnAddress,
                            onChanged: (bool value) {
                              if (!value) {
                                widget.onChanged(null);
                              } else {
                                if (this._toAddress != null) widget.onChanged(this._toAddress.publicKey);
                              }
                              setState(() {
                                this._useCustomReturnAddress = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (this._useCustomReturnAddress)
                        AccountSelectAddressWidget(
                            showLabel: false,
                            label: Text(S.of(context).wallet_return_address, style: Theme.of(context).inputDecorationTheme.hintStyle),
                            onChanged: (newValue) {
                              setState(() {
                                _toAddress = newValue;
                              });
                              if (_useCustomReturnAddress) {
                                widget.onChanged(this._toAddress.publicKey);
                              }
                            }),
                      SizedBox(width: 20),
                    ])
                  ])))
        ]);
  }
}
