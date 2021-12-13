// ignore_for_file: unused_import

import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/prices_background.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_token_box.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/util/refresh_able_widget.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

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
  double _tetherPrice = 1.0;
  CurrencyEnum _currency = CurrencyEnum.USD;

  StreamSubscription<PricesLoadedEvent> _pricesLoadedEvent;

  @override
  void initState() {
    super.initState();
    _initTokens();
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_pricesLoadedEvent != null) {
      _pricesLoadedEvent.cancel();
      _pricesLoadedEvent = null;
    }
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
      _tetherPrice = sl<PricesBackgroundService>().tetherPrice().fiat;
      _currency = await sl<ISharedPrefsUtil>().getCurrency();

      if (_pricesLoadedEvent == null) {
        _pricesLoadedEvent = EventTaxiImpl.singleton().registerTo<PricesLoadedEvent>().listen((event) async {
          setState(() {
            _tetherPrice = event.tetherPrice.fiat;
            _currency = event.currency;
          });
        });
      }

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

    var row = Responsive.buildResponsive<LoanToken>(context, _tokens, 500, (el) => new VaultTokenBoxWidget(el, _currency, _tetherPrice));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: PrimaryScrollController(
            controller: new ScrollController(),
            child: LayoutBuilder(builder: (_, builder) {
              return buildVaultScreen(context);
            })));
  }
}
