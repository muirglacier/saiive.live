import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';

class VaultEditCollateralTokenScreen extends StatefulWidget {
  final LoanVaultAmount current;
  final AccountBalance balance;
  final Function(LoanVaultAmount loan, double newAmount) onCollateralChanged;

  VaultEditCollateralTokenScreen(this.current, this.balance, this.onCollateralChanged);

  @override
  State<StatefulWidget> createState() {
    return _VaultEditCollateralTokenScreen();
  }
}

class _VaultEditCollateralTokenScreen extends State<VaultEditCollateralTokenScreen> {
  var _amountController = TextEditingController(text: '');
  double _amount = 0;
  bool _valid = false;

  @override
  void initState() {
    super.initState();

    _amountController.text = widget.current.amount;
    _amountController.addListener(handleChange);
  }

  handleChange() async {
    double amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    double loanAmount = double.tryParse(widget.current.amount);
    bool valid = true;

    if (null == amount) {
      valid = false;
      return;
    }

    if (widget.balance == null) {
      if (loanAmount > amount) {
        valid = false;
      }
    }
    else {
      if (amount > widget.balance.balanceDisplay) {
        valid = false;
      }
    }

    if (!valid) {
      amount = null;
    }

    setState(() {
      _valid = valid;
      _amount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: StateContainer.of(context).curTheme.cardBackgroundColor,
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                              hintText: 'How much to change?',
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0)),
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true)),
                      Container(height: 10),
                      Text('Available: ' +
                          FundFormatter.format(widget.balance != null ? widget.balance.balanceDisplay : '0')),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text('Edit'),
                            onPressed: _amount == null
                                ? null : () {
                              this.widget.onCollateralChanged(widget.current, _amount);
                            },
                          )),
                      Container(height: 10),
                      if (!_valid) Text('Amount is invalid, insufficient funds')
                    ]))));
  }
}
