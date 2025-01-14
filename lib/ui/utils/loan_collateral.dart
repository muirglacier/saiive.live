import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';

class LoanCollateralWidget extends StatefulWidget {
  final LoanVault vault;
  final LoanVaultAmount amount;
  final LoanCollateral token;

  LoanCollateralWidget(this.vault, this.token, this.amount);

  @override
  _LoanCollateralWidget createState() => new _LoanCollateralWidget();
}

class _LoanCollateralWidget extends State<LoanCollateralWidget> {
  @override
  Widget build(BuildContext context) {
    var percentage = LoanHelper.calculateCollateralShare(double.tryParse(widget.vault.collateralValue), widget.amount, widget.token).toStringAsFixed(2) + '%';

    return InputChip(
      avatar: TokenIcon(widget.amount.symbolKey, height: 20),
      label: Text(widget.amount.symbol + ': ' + percentage),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (bool value) {},
    );
  }
}
