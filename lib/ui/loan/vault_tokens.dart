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
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_token_box.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/util/refresh_able_widget.dart';

class VaultTokensScreen extends RefreshableWidget {
  final _VaultTokensScreen _state = _VaultTokensScreen();

  VaultTokensScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void refresh() {
    _state?._initTokens();
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
    setState(() {
      _tokens = null;
    });

    var tokens = await sl.get<ILoansService>().getLoanTokens(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _tokens = tokens;
    });
  }

  buildVaultScreen(BuildContext context) {
    if (_tokens == null) {
      return LoadingWidget(text: S.of(context).loading);
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
    super.build(context);
    return Scaffold(body: LayoutBuilder(builder: (_, builder) {
      return buildVaultScreen(context);
    }));
  }
}
