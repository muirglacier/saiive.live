import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/loan_collateral.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoanCollateralsWidget extends StatefulWidget {
  final LoanVault vault;
  final List<LoanCollateral> collaterals;
  final List<LoanVaultAmount> tokens;

  LoanCollateralsWidget(this.vault, this.collaterals, this.tokens);

  @override
  _LoanCollateralsWidget createState() => new _LoanCollateralsWidget();
}

class _LoanCollateralsWidget extends State<LoanCollateralsWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> collaterals = [];

    for (int i = 0; i < widget.tokens.length; i++) {
      var amount = widget.tokens.elementAt(i);
      var token = widget.collaterals.firstWhere((element) => element.token.symbolKey == amount.symbolKey, orElse: () => null);

      collaterals.add(LoanCollateralWidget(widget.vault, token, amount));
    }

    if (collaterals.length == 0) {
      return Container();
    }

    return Wrap(
      spacing: 1,
      children: collaterals,
    );
  }
}
