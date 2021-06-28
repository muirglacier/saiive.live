import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

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
    Wakelock.enable();
    try {
      final wallet = sl.get<IWalletService>();
      await wallet.init();

      await wallet.addAccount(name: "DFI0", account: 0, chain: ChainType.DeFiChain);
      await wallet.addAccount(name: "BTC0", account: 0, chain: ChainType.Bitcoin);
      await wallet.close();

      await wallet.init();
      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    } finally {
      Wakelock.disable();
    }
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
          title: Text(S.of(context).wallet_new_creating_title),
        ),
        body: Container(child: Card(child: LoadingWidget(text: S.of(context).wallet_new_creating))));
  }
}
