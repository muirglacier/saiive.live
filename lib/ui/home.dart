import 'dart:io';

import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/dex/dex.dart';
import 'package:defichainwallet/ui/liquidity/liquitiy.dart';
import 'package:defichainwallet/ui/tokens/tokens.dart';
import 'package:defichainwallet/ui/wallet/wallet_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _NavigationEntry {
  final Icon icon;
  final String label;
  final Widget page;

  _NavigationEntry({this.icon, this.label, this.page});
}

class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static List<_NavigationEntry> _navigationEntries = [];

  void initMenu(BuildContext context) {
    _navigationEntries = [
      _NavigationEntry(icon: Icon(Icons.account_balance_wallet), label: S.of(context).home_wallet, page: WalletHomeScreen()),
      _NavigationEntry(icon: Icon(Icons.pie_chart), label: S.of(context).home_liquitiy, page: LiquidityScreen()),
      _NavigationEntry(icon: Icon(Icons.compare_arrows), label: S.of(context).home_dex, page: DexScreen()),
      _NavigationEntry(icon: Icon(Icons.radio_button_unchecked), label: S.of(context).home_tokens, page: TokensScreen())
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _buildContent(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      return Center(
        child: _navigationEntries.elementAt(_selectedIndex).page,
      );
    }

    final List<NavigationRailDestination> navBar = _navigationEntries.map((e) => NavigationRailDestination(icon: e.icon, label: Text(e.label))).toList();

    return Row(
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
            leading: SizedBox(height: 100, width: 200, child: Center(child: Text("TODO: Add current network, version, etc..."))),
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

    final List<BottomNavigationBarItem> bottomNavBar = _navigationEntries.map((e) => BottomNavigationBarItem(icon: e.icon, label: e.label)).toList();

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
    return Scaffold(body: _buildContent(context), bottomNavigationBar: _buildBottomNavBar(context));
  }
}
