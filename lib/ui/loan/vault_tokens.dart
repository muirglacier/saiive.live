// ignore_for_file: unused_import

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_token_box.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
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
    try {
      var tokens = await sl.get<ILoansService>().getLoanTokens(DeFiConstants.DefiAccountSymbol);

      setState(() {
        _tokens = tokens;
      });
    } catch (error) {
      sl.get<AppCenterWrapper>().trackEvent("loadVaultTokensError", <String, String>{"error": error.toString()});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    }
  }

  buildVaultScreen(BuildContext context) {
    if (_tokens == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    var row = Responsive.buildResponsive<LoanToken>(context, _tokens, 500, (el) => new VaultTokenBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
            child: Container(
                padding: EdgeInsets.all(10),
                child: AlertWidget(
                  S.of(context).loan_beta,
                  color: Colors.red,
                  alert: Alert.error,
                ))),
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
