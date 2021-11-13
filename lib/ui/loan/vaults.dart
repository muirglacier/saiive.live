import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_box.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/responsive.dart';

class VaultsScreen extends StatefulWidget {
  const VaultsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VaultsScreen();
  }
}

class _VaultsScreen extends State<VaultsScreen> {
  List<LoanVault> _vaults;

  @override
  void initState() {
    super.initState();

    _initVaults();
  }

  _initVaults() async {
    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys();
    var vaults = await sl
        .get<IVaultsService>()
        .getVaults(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _vaults = vaults;
    });
  }

  buildVaultScreen(BuildContext context) {
    if (_vaults == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    if (_vaults.length == 0) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: Container(
                    padding: new EdgeInsets.all(20),
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.shield, size: 64),
                Container(
                    child: Text('No vault crated',
                        style: Theme.of(context).textTheme.headline3),
                    padding: new EdgeInsets.only(top: 5)),
                Container(
                    child: Text(
                        'To get started, create a vault add add DFI and other tokens as collateral',
                        textAlign: TextAlign.center),
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

    var row = Responsive.buildResponsive<LoanVault>(
        context, _vaults, 500, (el) => new VaultBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row)),
      ],
    );
  }

  Widget _buildVaultEntry(LoanVault vault) {
    return Card(
        child:
            Text(vault.vaultId, style: Theme.of(context).textTheme.headline3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(S.of(context).loan_vaults)),
        body: LayoutBuilder(builder: (_, builder) {
          return buildVaultScreen(context);
        }));
  }
}
