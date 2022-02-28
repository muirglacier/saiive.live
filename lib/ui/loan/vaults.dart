import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/prices_background.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_faq.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/util/refresh_able_widget.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class VaultsScreen extends RefreshableWidget {
  final _state = _VaultsScreen();
  VaultsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void refresh() {
    // _state._initVaults();
  }
}

class _VaultsScreen extends State<VaultsScreen> with AutomaticKeepAliveClientMixin<VaultsScreen> {
  List<LoanVault> _vaults;

  double _tetherPrice = 1.0;
  CurrencyEnum _currency = CurrencyEnum.USD;

  StreamSubscription<PricesLoadedEvent> _pricesLoadedEvent;

  @override
  void initState() {
    super.initState();

    _initVaults();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_pricesLoadedEvent != null) {
      _pricesLoadedEvent.cancel();
      _pricesLoadedEvent = null;
    }
  }

  _initVaults() async {
    if (!this.mounted) {
      return;
    }

    setState(() {
      _vaults = null;
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

      var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys(onlyActive: true);

      var vaults = await sl.get<IVaultsService>().getMyVaults(DeFiConstants.DefiAccountSymbol, pubKeyList);

      setState(() {
        _vaults = vaults;
      });
    } catch (error) {
      sl.get<AppCenterWrapper>().trackEvent("loadVaultsError", <String, String>{"error": error.toString()});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    }
  }

  buildVaultScreen(BuildContext context) {
    if (_vaults == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    if (_vaults.length == 0) {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: Container(
                padding: new EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.shield, size: 64),
                    Container(child: Text(S.of(context).loan_no_vault_created, style: Theme.of(context).textTheme.headline3), padding: new EdgeInsets.only(top: 5)),
                    Container(child: Text(S.of(context).loan_vault_creation_info, textAlign: TextAlign.center), padding: new EdgeInsets.only(top: 5)),
                    Container(
                        child: ElevatedButton(
                          child: Text(S.of(context).loan_create_vault),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultCreateScreen()));
                          },
                        ),
                        padding: new EdgeInsets.only(top: 5)),
                    Container(
                        child: TextButton(
                          child: Text(S.of(context).loan_faq),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultFAQScreen()));
                          },
                        ),
                        padding: new EdgeInsets.only(top: 5))
                  ],
                )))
      ]);
    }

    var row = Responsive.buildResponsive<LoanVault>(context, _vaults, 500, (el) => new VaultBoxWidget(el, this._currency, this._tetherPrice));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row)),
        SliverToBoxAdapter(
            child: Container(
                child: Container(
                    child: TextButton(
                      child: Text(S.of(context).loan_faq),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultFAQScreen()));
                      },
                    ),
                    padding: new EdgeInsets.only(top: 5))))
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
