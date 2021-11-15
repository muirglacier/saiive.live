import 'dart:io';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/ui/accounts/accounts_screen.dart';
import 'package:saiive.live/ui/dex/dex.dart';
import 'package:saiive.live/ui/drawer.dart';
import 'package:saiive.live/ui/liquidity/liquidity.dart';
import 'package:saiive.live/ui/loan/vaults_home.dart';
import 'package:saiive.live/ui/settings/settings.dart';
import 'package:saiive.live/ui/tokens/tokens.dart';
import 'package:saiive.live/ui/update/app_update_alert_widget.dart';

// ignore: unused_import
import 'package:saiive.live/ui/wallet/wallet_buy.dart';
import 'package:saiive.live/ui/wallet/wallet_home.dart';
import 'package:saiive.live/ui/widgets/version_widget.dart';
import 'package:flutter/material.dart';

import 'addressbook/addressbook_screen.dart';

class NavigationEntry {
  final Icon icon;
  final String label;
  final Widget page;
  final bool visibleForBottomNav;
  final String routeSettingName;

  NavigationEntry(
      {this.icon,
      this.label,
      this.page,
      this.visibleForBottomNav = true,
      this.routeSettingName});
}

class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<NavigationEntry> _navigationEntries = [];
  final PageStorageBucket _storeBucket = PageStorageBucket();

  void initMenu(BuildContext context) {
    if (_navigationEntries.isEmpty) {
      _navigationEntries = [
        NavigationEntry(
            icon: Icon(Icons.account_balance_wallet),
            label: S.of(context).home_wallet,
            page: WalletHomeScreen(key: PageStorageKey('WalletHome')),
            routeSettingName: "/home"),
        NavigationEntry(
            icon: Icon(Icons.pie_chart),
            label: S.of(context).home_liquidity,
            page: LiquidityScreen(key: PageStorageKey('Liquidity')),
            routeSettingName: "/liqudity"),
        NavigationEntry(
            icon: Icon(Icons.compare_arrows),
            label: S.of(context).home_dex,
            page: DexScreen(key: PageStorageKey('DEX')),
            routeSettingName: "/dex"),
        NavigationEntry(
            icon: Icon(Icons.account_box),
            label: S.of(context).wallet_accounts,
            page: AccountsScreen(key: PageStorageKey('Accounts')),
            visibleForBottomNav: true,
            routeSettingName: "/accounts"),
        NavigationEntry(
            icon: Icon(Icons.import_contacts),
            label: S.of(context).addressbook,
            page: AddressBookScreen(key: PageStorageKey('AddressBook')),
            visibleForBottomNav: false,
            routeSettingName: "/addressbook"),
        // NavigationEntry(icon: Icon(Icons.add_shopping_cart), label: S.of(context).dfx_buy_title, page: DfxBuyScreen(), visibleForBottomNav: false, routeSettingName: "/buy_dfi"),
        NavigationEntry(
            icon: Icon(Icons.credit_card),
            label: S.of(context).loan_vaults,
            page: VaultsHomeScreen(key: PageStorageKey('Vaults')),
            visibleForBottomNav: false,
            routeSettingName: "/vaults"),
        NavigationEntry(
            icon: Icon(Icons.radio_button_unchecked),
            label: S.of(context).home_tokens,
            page: TokensScreen(key: PageStorageKey('Tokens')),
            visibleForBottomNav: false,
            routeSettingName: "/tokens"),
        NavigationEntry(
            icon: Icon(Icons.settings),
            label: S.of(context).settings,
            page: SettingsScreen(key: PageStorageKey('Settings')),
            visibleForBottomNav: false,
            routeSettingName: "/settings")
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _buildContent(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      return AppUpdateAlert(
          child: Center(
              child: PageStorage(
        bucket: _storeBucket,
        child: _navigationEntries[_selectedIndex].page,
      )));
    }

    final List<NavigationRailDestination> navBar = _navigationEntries
        .map((e) =>
            NavigationRailDestination(icon: e.icon, label: Text(e.label)))
        .toList();
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
            selectedIconTheme: IconThemeData(
                color: StateContainer.of(context).curTheme.primary),
            selectedLabelTextStyle:
                TextStyle(color: StateContainer.of(context).curTheme.primary),
            leading: Container(
                child: Column(children: [
              SizedBox(
                  width: 200,
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(S.of(context).wallet_home_network,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            VersionWidget(),
                            if (currentEnvironment !=
                                EnvironmentType.Production)
                              Text(EnvHelper.environmentToString(
                                  currentEnvironment))
                          ]),
                    ),
                    Divider(
                        color:
                            StateContainer.of(context).curTheme.backgroundColor)
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

    final List<BottomNavigationBarItem> bottomNavBar = _navigationEntries
        .where((a) => a.visibleForBottomNav)
        .map((e) => BottomNavigationBarItem(icon: e.icon, label: e.label))
        .toList();

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

  drawerNavigate(NavigationEntry nav) {
    if (nav.visibleForBottomNav) {
      setState(() {
        _selectedIndex = _navigationEntries.indexOf(nav);
      });
      Navigator.pop(context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: nav.routeSettingName),
          builder: (BuildContext context) => nav.page));
    }
  }

  @override
  Widget build(BuildContext context) {
    initMenu(context);
    StateContainer.of(context).scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: StateContainer.of(context).scaffoldKey,
        body: _buildContent(context),
        bottomNavigationBar: _buildBottomNavBar(context),
        drawer: SaiiveDrawer(_navigationEntries, drawerNavigate));
  }
}
