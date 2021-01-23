import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).settings)),
        body: Column(
          children: [
            Container(
                child: SizedBox(
                    width: 300,
                    child: RaisedButton(
                      child: Text("Remove seed"),
                      color: Theme.of(context).backgroundColor,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.setString(
                            DefiChainConstants.MnemonicKey, null);
                        await prefs.setBool(
                            DefiChainConstants.RecoveryPhraseTested, null);
                        await prefs.setInt(
                            DefiChainConstants.WorkingAccountKey, null);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Removed saved seed"),
                        ));
                      },
                    ))),
          ],
        ));
  }
}
