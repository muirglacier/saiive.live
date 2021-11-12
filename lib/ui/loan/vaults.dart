import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
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
    var vaults = await sl.get<IVaultsService>().getVaults(DeFiConstants.DefiAccountSymbol);

    setState(() {
      _vaults = vaults;
    });
  }

  buildVaultScreen(BuildContext context) {
    if (_vaults == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    var row = Responsive.buildResponsive<LoanVault>(context, _vaults, 500, (el) => new VaultBoxWidget(el));

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: Container(child: row)),
      ],
    );
  }

  Widget _buildVaultEntry(LoanVault vault) {
    return Card(child: Text(vault.vaultId, style: Theme.of(context).textTheme.headline3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Row(children: [Text(S.of(context).loan_vaults)])),
        body: LayoutBuilder(builder: (_, builder) {
          return buildVaultScreen(context);
        }));
  }
}
