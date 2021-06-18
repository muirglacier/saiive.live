import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/ui/model/available_themes.dart';
import 'package:saiive.live/ui/settings/settings_seed.dart';
import 'package:saiive.live/ui/settings/wallet_addresses.dart';
import 'package:saiive.live/ui/styles.dart';
import 'package:saiive.live/ui/utils/card-link.widget.dart';
import 'package:saiive.live/ui/utils/legal_entities.dart';
import 'package:saiive.live/ui/wallet/wallet_send.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/model/authentication_method.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
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
    var currentEnvironment = EnvHelper.getEnvironment();
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

    await sl.get<IVault>().setSeed(null);
    await sl.get<SharedPrefsUtil>().setPasswordHash(null);
    await sl.get<IWalletService>().close();
    await sl.get<IWalletService>().destroy();

    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S.of(context).settings_removed_seed),
    ));
  }

  Future doChainNetSwitch(ChainNet net, ChainNet old) async {
    sl.get<SharedPrefsUtil>().setNetwork(net);

    setState(() {
      _curNet = net;
    });

    await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, old);
    await sl.get<IWalletDatabaseFactory>().destroy(ChainType.Bitcoin, old);
    await sl.get<IWalletService>().close();
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
      await doChainNetSwitch(net, _curNet);
      return;
    }

    Widget okButton = TextButton(
      child: Text(S.of(context).ok),
      onPressed: () async {
        await doChainNetSwitch(net, _curNet);
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
    const itemPaddingLeft = 10.0;
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
                          CardItemWidget(S.of(context).settings_common, null, backgroundColor: Colors.transparent),
                          CardItemWidget(S.of(context).settings_set_password, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () async {
                              final unlockHandler = sl.get<IUnlockHandler>();
                              final oldPassword = await unlockHandler.getUnlockCode();
                              final newPassword = await unlockHandler.setNewPassword(context);

                              await sl.get<IVault>().reEncryptData(oldPassword, newPassword);
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          SizedBox(height: 5),
                          Padding(
                              padding: EdgeInsets.only(left: itemPaddingLeft + 5),
                              child: Container(
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
                              ))),
                          SizedBox(height: 5),
                          CardItemWidget(S.of(context).settings_network, null, backgroundColor: Colors.transparent),
                          Padding(
                              padding: EdgeInsets.only(left: itemPaddingLeft + 5),
                              child: Container(
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
                              ))),
                          CardItemWidget(S.of(context).settings_wallet, null, backgroundColor: Colors.transparent),
                          SizedBox(height: 5),
                          CardItemWidget(S.of(context).settings_remove_seed, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () {
                              doDeleteSeed();
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_seed, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsSeedScreen()));
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_logs, () async {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LogConsole(showCloseButton: true, dark: _theme == 1)));
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_wallet_addresses, () async {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletAddressesScreen()));
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_support, null, backgroundColor: Colors.transparent),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_live, "https://t.me/SmartDefiWallet", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_defichain_de, "https://t.me/defiblockchain_DE",
                              padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_defichain_en, "https://t.me/defiblockchain", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_wiki, "https://www.defichain-wiki.com", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_reddit, "https://www.reddit.com/r/defiblockchain/", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_github, "https://github.com/saiive/saiive.live", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardLinkItemWidget(S.of(context).settings_support_defichain, "https://defichain.com", padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).welcome_legal, null, backgroundColor: Colors.transparent),
                          LegalEntitiesWidget(EdgeInsets.only(left: itemPaddingLeft, right: 0)),
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => WalletSendScreen('DFI', ChainType.DeFiChain, toAddress: 'dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs')));
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
  }
}
