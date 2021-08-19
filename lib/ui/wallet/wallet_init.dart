import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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

      final defaultDfiWalletAccount = WalletAccount(Uuid().v4(),
          id: 0,
          chain: ChainType.DeFiChain,
          account: 0,
          walletAccountType: WalletAccountType.HdAccount,
          derivationPathType: DerivationPathType.BIP32,
          name: "DFI0",
          selected: true);
      final defaultBtcWalletAccount = WalletAccount(Uuid().v4(),
          id: 0, chain: ChainType.Bitcoin, account: 0, walletAccountType: WalletAccountType.HdAccount, derivationPathType: DerivationPathType.BIP32, name: "BTC0", selected: true);

      await wallet.addAccount(defaultDfiWalletAccount);
      await wallet.addAccount(defaultBtcWalletAccount);
      await wallet.close();

      await wallet.init();

      var walletAddress = await wallet.getNextWalletAddress(defaultDfiWalletAccount, false, AddressType.P2SHSegwit);
      walletAddress.name = ChainHelper.chainTypeString(ChainType.DeFiChain);
      await wallet.updateAddress(walletAddress);

      var btcWalletAddress = await wallet.getNextWalletAddress(defaultBtcWalletAccount, false, AddressType.P2SHSegwit);
      btcWalletAddress.name = ChainHelper.chainTypeString(ChainType.Bitcoin);
      await wallet.updateAddress(btcWalletAddress);

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
