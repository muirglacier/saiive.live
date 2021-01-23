import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'restore/recovery_phrase_restore.dart';

class WalletRestoreScreen extends StatefulWidget {
  WalletRestoreScreen();

  _WalletRestoreScreenState createState() => _WalletRestoreScreenState();
}

class _WalletRestoreScreenState extends State<WalletRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    return RestoreRecoveryPhraseScreen();
  }
}
