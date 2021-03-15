import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

class WalletInitScreen extends StatefulWidget {
  WalletInitScreen();

  @override
  State<StatefulWidget> createState() {
    return _WalletInitScreenScreen();
  }
}

class _WalletInitScreenScreen extends State<WalletInitScreen> {
  _WalletInitScreenScreen();

  Future initWallet() async {
    final wallet = sl.get<DeFiChainWallet>();

    final walletDb = sl.get<IWalletDatabase>();
    await walletDb.addAccount(name: "DFI0", account: 0, chain: ChainType.DeFiChain);
    await walletDb.addAccount(name: "BTC0", account: 0, chain: ChainType.Bitcoin);

    await wallet.init();

    Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
  }

  @override
  void initState() {
    super.initState();

    initWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(S.of(context).wallet_new_creating_title),
        ),
        body: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.up,
                children: [LoadingWidget(text: S.of(context).wallet_new_creating)])));
  }
}
