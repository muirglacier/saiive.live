import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/wallet/recovery_phrase_display.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:defichainwallet/ui/widgets/recovery_phrase_info.dart';
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
