import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/helper/env.dart';
import 'package:defichainwallet/helper/version.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/model/available_themes.dart';
import 'package:defichainwallet/ui/settings/settings_seed.dart';
import 'package:defichainwallet/ui/settings/wallet_addresses.dart';
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
  int _theme;

  ChainNet _curNet;

  @override
  void initState() {
    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openSettingsPage", <String, String>{});
    _init();
  }

  void _init() async {
    var currentEnvironment = new EnvHelper().getEnvironment();
    var version = await new VersionHelper().getVersion();
    var authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
    var theme = await sl.get<SharedPrefsUtil>().getTheme();
    var chainNet = await sl.get<SharedPrefsUtil>().getChainNetwork();

    setState(() {
      _currentEnvironment = currentEnvironment;
      _version = version;
      _authMethod = authMethod.getIndex();
      _theme = theme.getIndex();
      _curNet = chainNet;
    });
  }

  void doDeleteSeed() async {
    sl.get<AppCenterWrapper>().trackEvent("settingsDeleteSeed", {});

    await sl.get<IWalletDatabase>().clearTransactions();
    await sl.get<IWalletDatabase>().clearUnspentTransactions();

    await sl.get<IWalletDatabase>().destroy();
    await sl.get<IVault>().setSeed(null);
    await sl.get<DeFiChainWallet>().close();

    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).settings_removed_seed),
    ));
  }

  Future doChainNetSwitch(ChainNet net) async {
    sl.get<SharedPrefsUtil>().setNetwork(net);

    setState(() {
      _curNet = net;
    });

    await sl.get<IWalletDatabase>().close();
    await sl.get<IWalletDatabase>().destroy();
    await sl.get<DeFiChainWallet>().close();
    await sl.get<IHttpService>().init();

    Navigator.of(context).pushNamedAndRemoveUntil("/intro_accounts_restore", (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).settings_network_changed),
    ));
  }

  Future doChangeChainNet(ChainNet net) async {
    if (net == _curNet) {
      return;
    }

    if (net == ChainNet.Testnet) {
      await doChainNetSwitch(net);
      return;
    }

    Widget okButton = TextButton(
      child: Text(S.of(context).ok),
      onPressed: () async {
        await doChainNetSwitch(net);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(S.of(context).cancel),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(S.of(context).settings_change_network_title),
      content: Text(S.of(context).settings_change_network_text),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).settings)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: <Widget>[
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
                          SizedBox(height: 5),
                          Container(
                              child: DropdownButton<int>(
                            isExpanded: true,
                            value: _theme,
                            items: ThemeSetting.all().map((e) {
                              return new DropdownMenuItem<int>(
                                value: e.getIndex(),
                                child: Text(e.getDisplayName(context)),
                              );
                            }).toList(),
                            onChanged: (int val) {
                              setState(() {
                                _theme = val;
                              });

                              final theme = ThemeSetting(ThemeOptions.values[val]);
                              sl.get<AppCenterWrapper>().trackEvent("settingsSetTheme", <String, String>{"theme": theme.getDisplayName(context)});

                              sl.get<SharedPrefsUtil>().setTheme(theme).then((result) {
                                setState(() {
                                  StateContainer.of(context).updateTheme(theme);
                                });
                              });
                            },
                          )),
                          SizedBox(height: 5),
                          Container(
                              child: DropdownButton<ChainNet>(
                            isExpanded: true,
                            disabledHint: Text('testnet'),
                            value: _curNet,
                            onChanged: (e) async {
                              await doChangeChainNet(e);
                            },
                            items: ChainNet.values.map((e) {
                              return new DropdownMenuItem<ChainNet>(
                                value: e,
                                child: Text(ChainHelper.chainNetworkString(e)),
                              );
                            }).toList(),
                          )),
                          SizedBox(height: 5),
                          Container(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorPrimary),
                            child: Text(
                              S.of(context).settings_remove_seed,
                              style: TextStyle(color: StateContainer.of(context).curTheme.darkColor),
                            ),
                            onPressed: () async {
                              sl.get<AuthenticationHelper>().forceAuth(context, () {
                                doDeleteSeed();
                              });
                            },
                          )),
                          SizedBox(height: 5),
                          Container(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorPrimary),
                            child: Text(S.of(context).settings_show_seed, style: TextStyle(color: StateContainer.of(context).curTheme.darkColor)),
                            onPressed: () async {
                              sl.get<AuthenticationHelper>().forceAuth(context, () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsSeedScreen()));
                              });
                            },
                          )),
                          SizedBox(height: 5),
                          Container(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorPrimary),
                            child: Text("Show logs", style: TextStyle(color: StateContainer.of(context).curTheme.darkColor)),
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LogConsole(showCloseButton: true, dark: _theme == 1)));
                            },
                          )),
                          SizedBox(height: 5),
                          Container(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorPrimary),
                            child: Text("Show wallet addresses", style: TextStyle(color: StateContainer.of(context).curTheme.darkColor)),
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletAddressesScreen()));
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
                              child: ElevatedButton(
                            child: Text(
                              "dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs",
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                            ),
                            onPressed: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (BuildContext context) => WalletSendScreen('DFI', toAddress: 'dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs')));
                            },
                          )),
                          SizedBox(height: 20),
                          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              child: Text(_version, style: AppStyles.textStyleParagraph(context)),
                            ),
                          ]),
                          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              child: Text(_currentEnvironment.toString(), style: AppStyles.textStyleParagraph(context)),
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
                      )),
                    ],
                  ),
                ),
              ],
            )));

    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).settings)),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  (Column(
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
                          child: DropdownButton<int>(
                        isExpanded: true,
                        value: _theme,
                        items: ThemeSetting.all().map((e) {
                          return new DropdownMenuItem<int>(
                            value: e.getIndex(),
                            child: Text(e.getDisplayName(context)),
                          );
                        }).toList(),
                        onChanged: (int val) {
                          setState(() {
                            _theme = val;
                          });

                          final theme = ThemeSetting(ThemeOptions.values[val]);
                          sl.get<AppCenterWrapper>().trackEvent("settingsSetTheme", <String, String>{"theme": theme.getDisplayName(context)});

                          sl.get<SharedPrefsUtil>().setTheme(theme).then((result) {
                            setState(() {
                              StateContainer.of(context).updateTheme(theme);
                            });
                          });
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
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).backgroundColor),
                        child: Text(S.of(context).settings_remove_seed),
                        onPressed: () async {
                          sl.get<AuthenticationHelper>().forceAuth(context, () {
                            doDeleteSeed();
                          });
                        },
                      )),
                      Container(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).backgroundColor),
                        child: Text(S.of(context).settings_show_seed),
                        onPressed: () async {
                          sl.get<AuthenticationHelper>().forceAuth(context, () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsSeedScreen()));
                          });
                        },
                      )),
                      Container(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).backgroundColor),
                        child: Text("Show logs"),
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LogConsole()));
                        },
                      )),
                      Container(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).backgroundColor),
                        child: Text("Show wallet addresses"),
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletAddressesScreen()));
                        },
                      ))
                    ],
                  )),
                ]))));
  }
}
