import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_db.dart';
import 'package:defichainwallet/crypto/wallet/impl/wallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
