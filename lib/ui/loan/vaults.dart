import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';
import 'package:saiive.live/util/refresh_able_widget.dart';

class VaultsScreen extends RefreshableWidget {
  final _state = _VaultsScreen();
  VaultsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void refresh() {
    _state._initVaults();
  }
}

class _VaultsScreen extends State<VaultsScreen> with AutomaticKeepAliveClientMixin<VaultsScreen> {
  List<LoanVault> _vaults;

  @override
  void initState() {
    super.initState();

    _initVaults();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  _initVaults() async {
    setState(() {
      _vaults = null;
    });

    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys();
    var vaults = await sl.get<IVaultsService>().getMyVaults(DeFiConstants.DefiAccountSymbol, pubKeyList);

    setState(() {
      _vaults = vaults;
    });
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
                    Container(
                        child: Text(S.of(context).loan_vault_creation_info, textAlign: TextAlign.center),
                        padding: new EdgeInsets.only(top: 5)),
                    Container(
                        child: ElevatedButton(
                          child: Text(S.of(context).loan_create_vault),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultCreateScreen()));
                          },
                        ),
                        padding: new EdgeInsets.only(top: 5))
                  ],
                )))
      ]);
    }

    var row = Responsive.buildResponsive<LoanVault>(context, _vaults, 500, (el) => new VaultBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(padding: EdgeInsets.all(10), child: AlertWidget(S.of(context).loan_beta, color: Colors.red, alert: Alert.error,))),
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
