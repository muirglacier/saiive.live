import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/loading.control.dart';
import 'package:defichainwallet/ui/wallet/init/create/recovery_phrase_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;

class WalletInitScreen extends StatefulWidget {
  WalletInitScreen();

  _WalletInitScreenState createState() => _WalletInitScreenState();
}

class _WalletInitScreenState extends State<WalletInitScreen> {
  var recoveryPhrase;

  @override
  void initState() {
    super.initState();

    setState(() {
      recoveryPhrase = bip39.generateMnemonic(strength: 256);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recoveryPhrase == "" || recoveryPhrase == null) {
      return LoadingControl(text: S.of(context).loading);
    }

    return RecoveryPhraseInfoScreen(mnemonic: recoveryPhrase);
  }
}
