import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:flutter/material.dart';

class VaultAddCollateralAmountScreen extends StatefulWidget {
  final AccountBalance token;
  final double addedAmount;
  final Function(double amount) onCollateralChanged;

  VaultAddCollateralAmountScreen(this.token, this.addedAmount, this.onCollateralChanged);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateralAmountScreen();
  }
}

class _VaultAddCollateralAmountScreen extends State<VaultAddCollateralAmountScreen> {
  var _amountController = TextEditingController(text: '');
  double _amount = 0;
  bool _valid = false;

  @override
  void initState() {
    super.initState();

    _amountController.addListener(handleChange);
  }

  handleChange() async {
    double amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    bool valid = true;

    if (null == amount) {
      valid = false;
      return;
    }

    if (amount + widget.addedAmount > widget.token.balanceDisplay) {
      valid = false;
    }

    if (!valid) {
      amount = null;
    }

    setState(() {
      _amount = amount;
      _valid = valid;
    });
  }

  handleSetMax() async {
    if (widget.token == null) {
      return;
    }
    setState(() {
      _amountController.text = widget.token.balanceDisplay.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: StateContainer.of(context).curTheme.cardBackgroundColor,
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: S.of(context).loan_change_collateral_how_much,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        suffixIcon: ElevatedButton(
                            child: Text(S.of(context).liquidity_add_max),
                            onPressed: () {
                              handleSetMax();
                            }),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  Container(height: 10),
                  Text(S.of(context).loan_add_collateral_available + ': ' + FundFormatter.format(widget.token.balanceDisplay - widget.addedAmount)),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(S.of(context).liquidity_add),
                        onPressed: _amount == null || _amount == 0
                            ? null
                            : () {
                                this.widget.onCollateralChanged(_amount);
                              },
                      )),
                  Container(height: 10),
                  if (!_valid) Text(S.of(context).loan_add_collateral_insufficient_funds)
                ]))));
  }
}
