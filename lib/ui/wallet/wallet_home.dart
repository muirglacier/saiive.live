import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_db.dart';
import 'package:defichainwallet/crypto/wallet/impl/wallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WalletHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletHomeScreenScreen();
  }
}

class _WalletHomeScreenScreen extends State<WalletHomeScreen> {
  IWallet _wallet;

  Map<String, double> _accountBalance;

  initWallet() async {
    final wallet = Wallet("", 0, ChainType.DeFiChain, ChainNet.Testnet);
    await wallet.init();

    final accounts = await wallet.getAccounts();
    if (accounts.length == 0) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/intro_accounts_restore", (route) => false);
    }

    await wallet.syncWallet();

    var accountBalance = await WalletDatabase.instance.getTotalBalances();

    setState(() {
      _wallet = wallet;
      _accountBalance = accountBalance;
    });
  }

  @override
  void initState() {
    super.initState();

    initWallet();
  }

  Widget _buildAccountEntry(String token, double balance) {
    return Card(
        child: ListTile(
      leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.account_balance_wallet)]),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(token, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Text(token, style: TextStyle(fontSize: 12))
          ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(balance.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
          ]),
    ));
  }

  buildWalletScreen(BuildContext context) {
    if (_accountBalance == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return Padding(
        padding: EdgeInsets.all(30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  child: Center(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemExtent: 100.0,
                          itemCount: _accountBalance.keys.length,
                          itemBuilder: (context, index) {
                            final account =
                                _accountBalance.keys.elementAt(index);
                            return _buildAccountEntry(
                                _accountBalance.keys.elementAt(index),
                                _accountBalance[account]);
                          })))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildWalletScreen(context));
  }
}
