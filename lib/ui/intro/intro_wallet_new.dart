import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:defichainwallet/ui/widgets/recovery_phrase_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bip39/bip39.dart' as bip39;

class IntroWalletNewScreen extends StatefulWidget {
  @override
  _IntroWalletNewScreenState createState() => _IntroWalletNewScreenState();
}

class _IntroWalletNewScreenState extends State<IntroWalletNewScreen> {
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
      return LoadingWidget(text: S.of(context).loading);
    }
    return RecoveryPhraseInfoWidget(mnemonic: recoveryPhrase);
  }
}
