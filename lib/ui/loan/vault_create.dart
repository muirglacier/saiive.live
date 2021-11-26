import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/loan/vault_create_confirm.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:flutter/material.dart';

class VaultCreateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VaultCreateScreen();
  }
}

class VaultCreateLoanSchemeItem extends StatelessWidget {
  const VaultCreateLoanSchemeItem({this.minCollateralRatio, this.interestRate});

  final String minCollateralRatio;
  final String interestRate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(S.of(context).loan_min_collateral_ratio, style: Theme.of(context).textTheme.caption), Text(this.minCollateralRatio + ' %')],
            )),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(S.of(context).loan_vault_interest_rate_apr, style: Theme.of(context).textTheme.caption), Text(this.interestRate + ' %')],
            ))
          ]))
        ],
      ),
    );
  }
}

class _VaultCreateScreen extends State<VaultCreateScreen> {
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
    });
  }

  buildCreateVaultScreen(BuildContext context) {
    if (_schemes == null) {
      return LoadingWidget(text: S.of(context).loading);
    }

    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(S.of(context).loan_create_choose_scheme, style: Theme.of(context).textTheme.headline6),
              Container(height: 10),
              Text(S.of(context).loan_create_choose_schema_info),
              Container(height: 10),
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
                      onPressed: _selectedSchema == null
                          ? null
                          : () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VaultCreateConfirmScreen(_selectedSchema)));
                            }))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_create_vault)), body: buildCreateVaultScreen(context));
  }
}
