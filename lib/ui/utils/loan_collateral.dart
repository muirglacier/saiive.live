import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';

class LoanCollateral extends StatefulWidget {
  final LoanVaultAmount token;

  LoanCollateral(this.token);

  @override
  _LoanCollateral createState() => new _LoanCollateral();
}

class _LoanCollateral extends State<LoanCollateral> {
  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: TokenIcon(widget.token.symbolKey),
      label: Text(widget.token.symbol + ': ' + double.tryParse(widget.token.amount).toStringAsPrecision(2) + '%'),
      onSelected: (bool value) {},
    );
  }
}
