// ignore_for_file: unused_import

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/loan/vault_token_box.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';

class VaultTokensScreen extends StatefulWidget {
  const VaultTokensScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VaultTokensScreen();
  }
}

class _VaultTokensScreen extends State<VaultTokensScreen> with AutomaticKeepAliveClientMixin<VaultTokensScreen> {
  List<LoanToken> _tokens;

  @override
  void initState() {
    super.initState();
    _initTokens();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  _initTokens() async {
    var tokens = await sl.get<ILoansService>().getLoanTokens(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _tokens = tokens;
    });
  }

  buildVaultScreen(BuildContext context) {
    if (_tokens == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    if (_tokens.length == 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: Container(
                padding: new EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.shield, size: 64),
                    Container(child: Text('No vault crated', style: Theme.of(context).textTheme.headline3), padding: new EdgeInsets.only(top: 5)),
                    Container(
                        child: Text('To get started, create a vault add add DFI and other tokens as collateral', textAlign: TextAlign.center),
                        padding: new EdgeInsets.only(top: 5)),
                    Container(
                        child: ElevatedButton(
                          child: Text('Create Vault'),
                          onPressed: () {
                            //TODO
                          },
                        ),
                        padding: new EdgeInsets.only(top: 5))
                  ],
                )))
      ]);
    }

    var row = Responsive.buildResponsive<LoanToken>(context, _tokens, 500, (el) => new VaultTokenBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (_, builder) {
      return buildVaultScreen(context);
    }));
  }
}
