import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/accounts/account_select_address_widget.dart';
import 'package:saiive.live/ui/utils/webview.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class DfxBuyWidget extends StatefulWidget {
  DfxBuyWidget();

  @override
  State<StatefulWidget> createState() {
    return _DfxBuyWidget();
  }
}

class _DfxBuyWidget extends State<DfxBuyWidget> {
  String dfxPaymentUrl = 'https://payment.dfx.swiss';

  bool _isSingleAddressWallet = false;

  String _buyAddress;

  void init() async {
    var isSingleAddressWallet = await sl.get<ISharedPrefsUtil>().getUseSingleAddressWallet();

    if (isSingleAddressWallet) {
      _buyAddress = await sl.get<IWalletService>().getPublicKey(ChainType.DeFiChain);
    }

    setState(() {
      _isSingleAddressWallet = isSingleAddressWallet;
    });
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<String> buildUrl(String address) async {
    var lang = StateContainer.of(context).curLanguage;

    var signature = await signMessage(address);
    var url = "$dfxPaymentUrl/login?address=$address&code=001-639&signature=${Uri.encodeComponent(signature)}&walletId=3&lang=${lang.language.toString()}";

    return url;
  }

  Future<String> signMessage(String address) async {
    final wallet = sl.get<DeFiChainWallet>();
    var message = "By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_$address";
    return await wallet.signMessage(address, message);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountSelectAddressWidget(
            label: Text(S.of(context).dfx_buy_address, style: Theme.of(context).inputDecorationTheme.hintStyle),
            onChanged: (newValue) {
              setState(() {
                _buyAddress = newValue.publicKey;
              });
            }),
        ElevatedButton(
            onPressed: _buyAddress == null
                ? null
                : () async {
                    var url = await buildUrl(_buyAddress);
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => WebViewScreen(url, "DFX.swiss", canOpenInBrowser: true)));
                    }
                  },
            child: Text("Buy"))
      ],
    );
  }
}
