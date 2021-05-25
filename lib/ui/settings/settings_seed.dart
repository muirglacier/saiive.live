import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/wallet/recovery_phrase_display.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsSeedScreen extends StatefulWidget {
  SettingsSeedScreen();

  _SettingsSeedScreenState createState() => _SettingsSeedScreenState();
}

class _SettingsSeedScreenState extends State<SettingsSeedScreen> {
  var _seed;

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    var seed = await sl.get<IVault>().getSeed();

    setState(() {
      _seed = seed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seed == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return RecoveryPhraseDisplayScreen(_seed, showNextButton: false);
  }
}
