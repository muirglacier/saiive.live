import 'dart:math';

import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/loan_collateral.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoanCollaterals extends StatefulWidget {
  final List<LoanVaultAmount> tokens;

  LoanCollaterals(this.tokens);

  @override
  _LoanCollaterals createState() => new _LoanCollaterals();
}

class _LoanCollaterals extends State<LoanCollaterals> {
  @override
  Widget build(BuildContext context) {
    List<Widget> collaterals = [];

    for (int i = 0; i < widget.tokens.length; i++) {
      collaterals.add(LoanCollateral(widget.tokens.elementAt(i)));
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
