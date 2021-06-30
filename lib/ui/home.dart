import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/version.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/accounts/accounts_screen.dart';
import 'package:saiive.live/ui/dex/dex.dart';
import 'package:saiive.live/ui/drawer.dart';
import 'package:saiive.live/ui/liquidity/liquidity.dart';
import 'package:saiive.live/ui/settings/settings.dart';
import 'package:saiive.live/ui/tokens/tokens.dart';
import 'package:saiive.live/ui/wallet/wallet_home.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationEntry {
  final Icon icon;
  final String label;
  final Widget page;
  final bool visibleForBottomNav;

  NavigationEntry({this.icon, this.label, this.page, this.visibleForBottomNav = true});
}

class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  ChainNet _currentNet = ChainNet.Testnet;
  EnvironmentType _environmentType = EnvironmentType.Unknonw;

  String _version = "";

  static List<NavigationEntry> _navigationEntries = [];

  void initMenu(BuildContext context) {
    _navigationEntries = [
      NavigationEntry(icon: Icon(Icons.account_balance_wallet), label: S.of(context).home_wallet, page: WalletHomeScreen()),
      NavigationEntry(icon: Icon(Icons.pie_chart), label: S.of(context).home_liquidity, page: LiquidityScreen()),
      NavigationEntry(icon: Icon(Icons.compare_arrows), label: S.of(context).home_dex, page: DexScreen()),
      NavigationEntry(icon: Icon(Icons.radio_button_unchecked), label: S.of(context).home_tokens, page: TokensScreen()),
      NavigationEntry(icon: Icon(Icons.account_box), label: S.of(context).wallet_accounts, page: AccountsScreen(), visibleForBottomNav: false),
      NavigationEntry(icon: Icon(Icons.settings), label: S.of(context).settings, page: SettingsScreen(), visibleForBottomNav: false)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _environmentType = EnvHelper.getEnvironment();
    _currentNet = await sl.get<SharedPrefsUtil>().getChainNetwork();
    _version = await VersionHelper().getVersion();

    setState(() {});
  }

  _buildContent(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      return Center(
        child: _navigationEntries.elementAt(_selectedIndex).page,
      );
    }

    final List<NavigationRailDestination> navBar = _navigationEntries.map((e) => NavigationRailDestination(icon: e.icon, label: Text(e.label))).toList();
    var currentEnvironment = EnvHelper.getEnvironment();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        NavigationRail(
            backgroundColor: StateContainer.of(context).curTheme.lightColor,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(color: StateContainer.of(context).curTheme.primary),
            selectedLabelTextStyle: TextStyle(color: StateContainer.of(context).curTheme.primary),
            leading: Container(
                child: Column(children: [
              SizedBox(
                  width: 200,
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text(S.of(context).wallet_home_network, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(ChainHelper.chainNetworkString(_currentNet)), Text(_version)]),
                        if (currentEnvironment != EnvironmentType.Production) Text(EnvHelper.environmentToString(currentEnvironment))
                      ]),
                    ),
                    Divider(color: StateContainer.of(context).curTheme.backgroundColor)
                  ]))
            ])),
            destinations: navBar),
        VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: Center(
            child: _navigationEntries.elementAt(_selectedIndex).page,
          ),
        )
      ],
    );
  }

  _buildBottomNavBar(BuildContext context) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return null;
    }

    final List<BottomNavigationBarItem> bottomNavBar =
        _navigationEntries.where((a) => a.visibleForBottomNav).map((e) => BottomNavigationBarItem(icon: e.icon, label: e.label)).toList();

    return BottomNavigationBar(
      items: bottomNavBar,
      currentIndex: _selectedIndex,
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).hintColor,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }

  @override
  Widget build(BuildContext context) {
    initMenu(context);
    StateContainer.of(context).scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: StateContainer.of(context).scaffoldKey,
        body: _buildContent(context),
        bottomNavigationBar: _buildBottomNavBar(context),
        drawer: DrawerUtil.createDrawer(context, _navigationEntries, (nav) {
          setState(() {
            if (nav.visibleForBottomNav) {
              _selectedIndex = _navigationEntries.indexOf(nav);

              Navigator.pop(context);
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => nav.page));
            }
          });
        }, env: _environmentType, network: _currentNet, version: _version));
  }
}
