import 'dart:io';

import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/widgets/mnemonic_seed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IntroRestoreScreen extends StatefulWidget {
  @override
  _IntroRestoreScreenState createState() => _IntroRestoreScreenState();
}

class _IntroRestoreScreenState extends State<IntroRestoreScreen> {
  List<String> _phrase = [];

  @override
  Widget build(BuildContext context) {
    if (env["ENV"] == "dev") {
      var demoWords2 = "bubble year chase pair benefit swarm ripple pottery price device receive gain over loud give reopen point input menu execute daring much prefer sauce";

      if (Platform.isAndroid || Platform.isWindows) {
        demoWords2 = "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow";
      }

      //WOLFI
      //demoWords2 = "glad village quantum off rely pretty emerge predict clump orphan crater space monster sleep trip remain cute into village drip proud siren clean middle";
      _phrase = demoWords2.split(" ");
    }

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).welcome_wallet_restore)),
      body: MnemonicSeedWidget(words: _phrase)
    );
  }
}
