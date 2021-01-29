import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class DexScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DexScreen();
  }
}

class _DexScreen extends State<DexScreen> {
  String _selectedValueTo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).dex)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton<String>(
                isExpanded: true,
                hint: Text("Status"),
                value: 'DFI',
                items: <String>['DFI']
                    .map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text("Status"),
                value: _selectedValueTo,
                items: <String>['BTC', 'ETH', 'USDT']
                    .map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (String val) {
                  setState(() {
                    _selectedValueTo = val;
                  });
                },
              )
            ])));
  }
}
