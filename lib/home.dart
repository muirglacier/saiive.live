import 'package:defichainwallet/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'wallet/wallet.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    WalletScreen(),
    Text(
      'Liquidity - Work in Progress!',
      style: optionStyle,
    ),
    Text(
      'DEX - Work in Progress!',
      style: optionStyle,
    ),
    Text(
      'Tokens - Work in Progress!',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).home_wallet),
        actionsIconTheme: Theme.of(context).iconTheme,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => SettingsScreen()));
                },
                child: Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              ))
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: S.of(context).home_wallet,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: S.of(context).home_liquitiy,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: S.of(context).home_dex,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.radio_button_unchecked),
              label: S.of(context).home_tokens)
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).hintColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
