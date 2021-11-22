import 'package:flutter/services.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/loading.dart';

class VaultPaybackLoanScreen extends StatefulWidget {
  final LoanVaultAmount loanAmount;
  final LoanToken loanToken;
  final LoanVault loanVault;


  VaultPaybackLoanScreen(this.loanAmount, this.loanToken, this.loanVault);

  @override
  State<StatefulWidget> createState() {
    return _VaultPaybackLoanScreen();
  }
}

class _VaultPaybackLoanScreen extends State<VaultPaybackLoanScreen> {
  double percentage = 100;
  double amountToRemove = 0;
  int availableBalance = 0;
  bool balanceLoaded = false;
  var _percentageTextController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();

    loadBalance();

    handleChangePercentage();
    _percentageTextController.addListener(handleChangePercentage);
  }

  loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    var tokenBalance = accountBalance.firstWhere((element) => element.token == widget.loanAmount.symbol, orElse: () => null);

    setState(() {
      balanceLoaded = true;
      availableBalance = tokenBalance != null ? tokenBalance.balance : 0;
    });

  }

  handleChangePercentage() {
    double amount = double.tryParse(_percentageTextController.text.replaceAll(',','.'));

    if (amount == null) {
      return;
    }

    setState(() {
      percentage = amount;
      amountToRemove = (double.tryParse(widget.loanAmount.amount) / 100) * amount;
    });
  }

  Widget _buildRemove(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Column(children: [
        Row(children: [
          SizedBox(
            width: 80,
            child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter(RegExp(r"^(100(\.0{1,2})?|[1-9]?\d(\.\d{1,2})?)"), allow: true)],
                textAlign: TextAlign.right,
                decoration: InputDecoration(labelText: '', counterText: '', suffix: Text('%')),
                controller: _percentageTextController),
          ),
          Expanded(
              flex: 4,
              child: Slider(
                value: percentage,
                min: 0,
                max: 100,
                label: percentage.round().toString() + '%',
                onChanged: (double value) {
                  setState(() {
                    percentage = value;

                    _percentageTextController.text = value.toStringAsFixed(1);
                  });
                },
              ))
        ]),
        if (percentage > 0)
          ElevatedButton(
            child: Text('Payback'),
            onPressed: () async {

            },
          )
      ])
    ]);
  }

  buildAmount() {
    var pricePerToken = widget.loanAmount.activePrice != null ? widget.loanAmount.activePrice.active.amount : 0;
    var totalAmount = pricePerToken * double.tryParse(widget.loanAmount.amount);

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[
                TokenIcon(widget.loanAmount.symbol),
                Container(width: 5),
                Text(widget.loanAmount.displaySymbol)
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Borrowed Tokens',
                      style: Theme.of(context).textTheme.caption),
                  Text(
                      'Interest amount (${widget.loanVault.schema.interestRate} %)',
                      style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(double.tryParse(widget.loanAmount.amount))),
                  Text(FundFormatter.format(
                      double.tryParse(widget.loanAmount.amount) *
                          double.tryParse(widget.loanVault.schema.interestRate) /
                          100,
                      fractions: 4))
                ]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Amount Payable',
                      style: Theme.of(context).textTheme.caption),
                  Text('Price per Token',
                      style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(totalAmount, fractions: 2) + ' \$'),
                  Text(
                      FundFormatter.format(pricePerToken, fractions: 2) + ' \$')
                ]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Available Balance',
                      style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(availableBalance / DefiChainConstants.COIN)),
                ]),
              ])
            ])));
  }

  buildPayback() {
    var pricePerToken = widget.loanAmount.activePrice != null ? widget.loanAmount.activePrice.active.amount : 0;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text('Tokens to pay back',
                      style: Theme.of(context).textTheme.caption),
                  Text(
                      'Value')
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(amountToRemove)),
                  Text(FundFormatter.format(
                      amountToRemove*pricePerToken,
                      fractions: 4))
                ]),
              ])
            ])));
  }

  @override
  Widget build(Object context) {
    if (!balanceLoaded) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text("Payback Loan")),
          body: LoadingWidget(text: S.of(context).loading));
    }

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text("Payback Loan")),
        body: Padding(padding: EdgeInsets.all(20), child: Column(children: [buildAmount(), buildPayback(), _buildRemove(context)])));
  }
}
