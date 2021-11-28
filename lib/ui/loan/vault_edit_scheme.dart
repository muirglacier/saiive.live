import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_create.dart';
import 'package:saiive.live/ui/loan/vault_create_confirm.dart';
import 'package:saiive.live/ui/loan/vault_edit_scheme_confirm.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:saiive.live/ui/widgets/vault_status.dart';

class VaultEditSchemeScreen extends StatefulWidget {
  final LoanVault vault;

  VaultEditSchemeScreen(this.vault);

  @override
  State<StatefulWidget> createState() {
    return _VaultEditSchemeScreen();
  }
}

class _VaultEditSchemeScreen extends State<VaultEditSchemeScreen> {
  List<LoanSchema> _schemes;
  List<bool> _selection;
  LoanSchema _selectedSchema;

  @override
  void initState() {
    super.initState();

    _initSchemes();
  }

  _initSchemes() async {
    var schemes = await sl.get<ILoansService>().getLoanSchemas(DeFiConstants.DefiAccountSymbol);

    schemes.sort((a, b) => double.tryParse(a.interestRate).compareTo(double.tryParse(b.interestRate)) * -1);

    _selection = List.filled(schemes.length, false);

    setState(() {
      _schemes = schemes;
      _selectedSchema = _schemes.firstWhere((element) => element.id == widget.vault.schema.id, orElse: () => null);
    });
  }

  Widget _buildTopPart() {
    List<List<String>> items = [
      [S.of(context).loan_total_collateral, widget.vault.collateralValue + ' \$'],
      [S.of(context).loan_total_loan_usd, widget.vault.loanValue + ' \$'],
      [S.of(context).loan_collateral_ratio, widget.vault.collateralRatio + '%'],
      [S.of(context).loan_min_collateral_ratio, widget.vault.schema.minColRatio + '%'],
    ];

    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Card(
              child: Padding(padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    VaultStatusWidget(widget.vault.healthStatus),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(decoration: BoxDecoration(color: Colors.transparent), child: Icon(Icons.shield, size: 40)),
                      Container(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SelectableText(
                              widget.vault.vaultId,
                              maxLines: 4,
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ]))
                    ]),
                  ])))
        , CustomTableWidget(items)]));
  }

  buildEditVaultScreen(BuildContext context) {
    if (_schemes == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
            child:_buildTopPart()),
            SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _schemes.length,
                        itemBuilder: (context, index) {
                          final navItem = _schemes[index];

                          return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: _selection[index] ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.appBarText)),
                              child: ListTile(
                                  leading: Icon(_selection[index] ? Icons.radio_button_checked : Icons.radio_button_off),
                                  title: VaultCreateLoanSchemeItem(minCollateralRatio: navItem.minColRatio, interestRate: navItem.interestRate),
                                  onTap: () {
                                    setState(() {
                                      //here am trying to implement single selection for the options in the list but it don't work well
                                      for (int i = 0; i < _schemes.length; i++) {
                                        if (i == index) {
                                          setState(() {
                                            _selection[i] = true;
                                          });
                                        } else {
                                          setState(() {
                                            _selection[i] = false;
                                          });
                                        }

                                        _selectedSchema = _schemes[index];
                                      }
                                    });
                                  }));
                        }),
                    // Text('Keep note of your selected collateral ratio for your vault to sustain the loans within it', style: Theme.of(context).textTheme.caption),
                    // Container(height: 20),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            child: Text(S.of(context).loan_continue),
                            onPressed: _selectedSchema == null || _selectedSchema.id == widget.vault.schema.id
                                ? null
                                : () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultEditSchemeConfirmScreen(widget.vault, _selectedSchema)));
                            }))
                  ]))
            )
          ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_edit_scheme)), body: buildEditVaultScreen(context));
  }
}
