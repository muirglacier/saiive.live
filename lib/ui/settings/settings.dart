import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/env.dart';
import 'package:defichainwallet/helper/version.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/settings/settings_seed.dart';
import 'package:defichainwallet/ui/styles.dart';
import 'package:defichainwallet/ui/wallet/wallet_send.dart';
import 'package:defichainwallet/ui/utils/authentication_helper.dart';
import 'package:defichainwallet/ui/model/authentication_method.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _version = "";
  EnvironmentType _currentEnvironment;
  int _authMethod;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    var currentEnvironment = new EnvHelper().getEnvironment();
    var version = await new VersionHelper().getVersion();
    var authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();

    setState(() {
      _currentEnvironment = currentEnvironment;
      _version = version;
      _authMethod = authMethod.getIndex();
    });
  }

  void doDeleteSeed() async {
    await sl.get<IWalletDatabase>().destroy();
    await sl.get<IVault>().setSeed(null);
    await sl.get<DeFiChainWallet>().close();

    Navigator.of(context)
        .pushNamedAndRemoveUntil("/", (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).settings_removed_seed),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).settings)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      child: DropdownButton<int>(
                    isExpanded: true,
                    value: _authMethod,
                    items: AuthenticationMethod.all().map((e) {
                      return new DropdownMenuItem<int>(
                        value: e.getIndex(),
                        child: Text(e.getDisplayName(context)),
                      );
                    }).toList(),
                      onChanged: (int val) {
                        setState(() {
                          _authMethod = val;
                        });

                        sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.values[val]));
                      },
                  )),
                  Container(
                      child: DropdownButton<String>(
                    isExpanded: true,
                    disabledHint: Text('testnet'),
                    value: null,
                    items: ['testnet', 'mainnet'].map((e) {
                      return new DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  )),
                  Container(
                      child: RaisedButton(
                    child: Text(S.of(context).settings_remove_seed),
                    color: Theme.of(context).backgroundColor,
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () { doDeleteSeed(); });
                    },
                  )),
                  Container(
                      child: RaisedButton(
                    child: Text(S.of(context).settings_show_seed),
                    color: Theme.of(context).backgroundColor,
                    onPressed: () async {
                      sl.get<AuthenticationHelper>().forceAuth(context, () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SettingsSeedScreen()));
                      });
                    },
                  )),
                  if (_currentEnvironment != EnvironmentType.Production)
                    Container(
                        child: RaisedButton(
                      child: Text("Show logs"),
                      color: Theme.of(context).backgroundColor,
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => LogConsole()));
                      },
                    ))
                ],
              )),
              Container(
                  child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  Container(
                      child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            S.of(context).settings_donate,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ))),
                  Container(
                      child: RaisedButton(
                    child: Text("dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs",
                        style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => WalletSendScreen(
                              'DFI',
                              toAddress:
                                  'dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs')));
                    },
                  )),
                  SizedBox(height: 20),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(_version,
                              style: AppStyles.textStyleParagraph(context)),
                        ),
                      ]),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(_currentEnvironment.toString(),
                              style: AppStyles.textStyleParagraph(context)),
                        ),
                      ]),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        S.of(context).settings_disclaimer,
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ))
                ],
              ))
            ])));
  }
}
