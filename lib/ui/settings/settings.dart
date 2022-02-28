import 'dart:io';

import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/services.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/expert/expert_generate_address.dart';
import 'package:saiive.live/ui/expert/expert_screen.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/ui/model/available_themes.dart';
import 'package:saiive.live/ui/settings/settings_seed.dart';
import 'package:saiive.live/ui/settings/wallet_addresses.dart';
import 'package:saiive.live/ui/styles.dart';
import 'package:saiive.live/ui/utils/card-link.widget.dart';
import 'package:saiive.live/ui/utils/legal_entities.dart';
import 'package:saiive.live/ui/wallet/wallet_send.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/material.dart';
import 'package:logger_flutter_console/logger_flutter_console.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _version = "";
  EnvironmentType _currentEnvironment;
  int _theme;

  ChainNet _curNet;
  bool _useSingleAddressMode = false;
  CurrencyEnum _currency;

  @override
  void initState() {
    super.initState();

    sl.get<AppCenterWrapper>().trackEvent("openSettingsPage", <String, String>{});
    _init();
  }

  void _init() async {
    var currentEnvironment = EnvHelper.getEnvironment();
    var version = await new VersionHelper().getVersion();
    var theme = await sl.get<ISharedPrefsUtil>().getTheme();
    var chainNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
    var singleAddressMode = await sl.get<ISharedPrefsUtil>().getUseSingleAddressWallet();
    var currency = await sl.get<ISharedPrefsUtil>().getCurrency();

    setState(() {
      _currentEnvironment = currentEnvironment;
      _version = version;
      _theme = theme.getIndex();
      _curNet = chainNet;
      _useSingleAddressMode = singleAddressMode;
      _currency = currency;
    });
  }

  Future doResyncWallet() async {
    await destoryDatabase();
    Navigator.of(context).pushNamedAndRemoveUntil("/intro_accounts_restore", (route) => false);
  }

  Future destoryDatabase() async {
    var db = sl.get<IWalletDatabaseFactory>();
    await db.destroy(ChainType.Bitcoin, ChainNet.Mainnet);
    await db.destroy(ChainType.Bitcoin, ChainNet.Testnet);
    await db.destroy(ChainType.DeFiChain, ChainNet.Mainnet);
    await db.destroy(ChainType.DeFiChain, ChainNet.Testnet);
  }

  Future doDeleteSeed() async {
    sl.get<AppCenterWrapper>().trackEvent("settingsDeleteSeed", {});

    await destoryDatabase();

    await sl.get<IVault>().setSeed(null);
    await sl.get<ISharedPrefsUtil>().setPasswordHash(null);
    await sl.get<ISharedPrefsUtil>().setUseSingleAddressWallet(true);
    await sl.get<ISharedPrefsUtil>().resetInstanceId();
    await sl.get<IWalletService>().close();
    await sl.get<IWalletService>().destroy();

    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
  }

  Future doChainNetSwitch(ChainNet net, ChainNet old) async {
    sl.get<ISharedPrefsUtil>().setNetwork(net);

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

  Future doChangeSingleAddressMode(bool mode) async {
    Widget okButton = TextButton(
        child: Text(S.of(context).ok),
        onPressed: () async {
          await sl.get<ISharedPrefsUtil>().setUseSingleAddressWallet(mode);
          _useSingleAddressMode = mode;
          setState(() {});
          Navigator.of(context, rootNavigator: true).pop();
        });
    Widget cancelButton = TextButton(
      child: Text(S.of(context).cancel),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(S.of(context).wallet_use_single_address_mode),
      content: Text(S.of(context).wallet_single_address_mode_switch),
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

                                  sl.get<ISharedPrefsUtil>().setTheme(theme).then((result) {
                                    setState(() {
                                      StateContainer.of(context).updateTheme(theme);
                                    });
                                  });
                                },
                              ))),
                          SizedBox(height: 5),
                          Padding(
                              padding: EdgeInsets.only(left: itemPaddingLeft + 5),
                              child: Container(
                                  child: DropdownButton<CurrencyEnum>(
                                isExpanded: true,
                                value: _currency,
                                onChanged: (e) async {
                                  await sl.get<ISharedPrefsUtil>().setCurrency(e);
                                  EventTaxiImpl.singleton().fire(new PricesStartLoadEvent());
                                  _currency = e;
                                  setState(() {});
                                },
                                items: CurrencyEnum.values.map((e) {
                                  return new DropdownMenuItem<CurrencyEnum>(
                                    value: e,
                                    child: Text(Currency.getCurrencyName(e)),
                                  );
                                }).toList(),
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
                          CardItemWidget(S.of(context).wallet_use_single_address_mode, null, backgroundColor: Colors.transparent),
                          Padding(
                              padding: EdgeInsets.only(left: itemPaddingLeft + 5),
                              child: Container(
                                  child: DropdownButton<bool>(
                                isExpanded: true,
                                disabledHint: Text(S.of(context).yes),
                                value: _useSingleAddressMode,
                                onChanged: (e) async {
                                  await doChangeSingleAddressMode(e);
                                },
                                items: [true, false].map((e) {
                                  return new DropdownMenuItem<bool>(
                                    value: e,
                                    child: Text(e ? S.of(context).yes : S.of(context).no),
                                  );
                                }).toList(),
                              ))),
                          CardItemWidget(S.of(context).settings_wallet, null, backgroundColor: Colors.transparent),
                          SizedBox(height: 5),
                          CardItemWidget(S.of(context).settings_remove_seed, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () async {
                              await doDeleteSeed();
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).resync_wallet_from_seed, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () async {
                              await doResyncWallet();
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_seed, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsSeedScreen()));
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_logs, () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => LogConsole(
                                      showCloseButton: true,
                                      dark: _theme == 1,
                                      showCopyButton: true,
                                      copyCallback: (e) {
                                        ClipboardManager.copyToClipBoard(e).then((result) {
                                          ScaffoldMessenger.of(NavigationHelper.navigatorKey.currentContext).showSnackBar(SnackBar(
                                            content: Text(S.of(context).settings_logs_copied),
                                          ));
                                        });
                                        Clipboard.setData(new ClipboardData(text: e));
                                      },
                                    )));
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_show_wallet_addresses, () async {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WalletAddressesScreen()));
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).settings_support, null, backgroundColor: Colors.transparent),
                          CardLinkItemWidget("saiive.live", "https://www.saiive.live", padding: EdgeInsets.only(left: itemPaddingLeft), canOpenInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_live, "https://t.me/SmartDefiWallet",
                              padding: EdgeInsets.only(left: itemPaddingLeft), openInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_defichain_de, "https://t.me/defiblockchain_DE",
                              padding: EdgeInsets.only(left: itemPaddingLeft), openInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_telegram_defichain_en, "https://t.me/defiblockchain",
                              padding: EdgeInsets.only(left: itemPaddingLeft), openInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_wiki, "https://www.defichain-wiki.com",
                              padding: EdgeInsets.only(left: itemPaddingLeft), canOpenInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_reddit, "https://www.reddit.com/r/defiblockchain/",
                              padding: EdgeInsets.only(left: itemPaddingLeft), openInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_github, "https://github.com/saiive/saiive.live",
                              padding: EdgeInsets.only(left: itemPaddingLeft), canOpenInBrowser: true),
                          CardLinkItemWidget(S.of(context).settings_support_defichain, "https://defichain.com",
                              padding: EdgeInsets.only(left: itemPaddingLeft), canOpenInBrowser: true),
                          CardItemWidget(S.of(context).welcome_legal, null, backgroundColor: Colors.transparent),
                          LegalEntitiesWidget(EdgeInsets.only(left: itemPaddingLeft, right: 0)),
                          CardItemWidget(S.of(context).expert, null, backgroundColor: Colors.transparent),
                          CardItemWidget(S.of(context).expert_title, () async {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ExpertScreen()));
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                          CardItemWidget(S.of(context).expert_address_title, () async {
                            sl.get<AuthenticationHelper>().forceAuth(context, () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ExpertAddressScreen()));
                            });
                          }, padding: EdgeInsets.only(left: itemPaddingLeft)),
                        ],
                      )),
                      Container(
                          child: Column(
                        children: [
                          Image.asset('assets/logo.png', height: 100),
                          if (!Platform.isIOS)
                            Container(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      S.of(context).settings_donate,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ))),
                          if (!Platform.isIOS)
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
