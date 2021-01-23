import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:defichainwallet/ui/widgets/recovery_phrase_restore.dart';

class IntroRestoreScreen extends StatefulWidget {
  @override
  _IntroRestoreScreenState createState() => _IntroRestoreScreenState();
}

class _IntroRestoreScreenState extends State<IntroRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    return RestoreRecoveryPhraseScreen();
  }
}
