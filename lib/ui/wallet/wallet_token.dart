import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WalletTokenScreen extends StatefulWidget {
  final String token;
  WalletTokenScreen(this.token);

  @override
  State<StatefulWidget> createState() {
    return _WalletTokenScreen();
  }
}

class _WalletTokenScreen extends State<WalletTokenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.token)));
  }
}
