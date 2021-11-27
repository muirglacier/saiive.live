import 'dart:async';
import 'dart:math';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/services.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/events/vaults_sync_start_event.dart';
import 'package:saiive.live/network/events/wallet_sync_start_event.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/alert_widget.dart';
import 'package:saiive.live/ui/widgets/loading.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';
import 'package:wakelock/wakelock.dart';

class VaultPaybackLoanScreen extends StatefulWidget {
  final LoanVaultAmount loanAmount;
  final LoanToken loanToken;
  final LoanVault loanVault;
  final LoanVaultAmount loanInterest;

  VaultPaybackLoanScreen(this.loanAmount, this.loanToken, this.loanVault, this.loanInterest);

  @override
  State<StatefulWidget> createState() {
    return _VaultPaybackLoanScreen();
  }
}

class _VaultPaybackLoanScreen extends State<VaultPaybackLoanScreen> {
  double percentage = 100;
  int amountToRemove = 0;
  double amountToRemoveDouble = 0.0;
  int availableBalance = 0;
  bool balanceLoaded = false;
  var _percentageTextController = TextEditingController(text: '100');

  double totalVaultValue = 0.0;
  int totalVaultValueSat = 0;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    totalVaultValue = double.parse(widget.loanAmount.amount);
    totalVaultValueSat = (totalVaultValue * 100000000).round();
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

  doPaybakLoan() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    var streamController = StreamController<String>();
    try {
      var paybackLoan = wallet.paybackLoan(widget.loanVault.vaultId, widget.loanVault.ownerAddress, widget.loanToken.token.symbolKey, amountToRemove,
          returnAddress: _returnAddress, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(paybackLoan);

      EventTaxiImpl.singleton().fire(WalletSyncStartEvent());
      EventTaxiImpl.singleton().fire(VaultSyncStartEvent());

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, S.of(context).loan_payback_success),
      ));

      Navigator.of(context).pop();
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      streamController.close();
      Wakelock.disable();
    }
  }

  calculateMaxToPayback() {
    if (availableBalance > totalVaultValueSat) {
      _percentageTextController.text = "100.0";
    } else {
      var dif = min(availableBalance, totalVaultValueSat) / max(totalVaultValueSat, availableBalance);

      var difPercentage = dif * 100;
      _percentageTextController.text = difPercentage.toString();
    }
    handleChangePercentage();
  }

  handleChangePercentage() {
    double amount = double.tryParse(_percentageTextController.text.replaceAll(',', '.'));

    if (amount == null) {
      return;
    }
    double toRemove = 0;
    percentage = amount;
    if (percentage == 100) {
      toRemove = totalVaultValue;
    } else {
      toRemove = (totalVaultValue / 100) * amount;
    }

    setState(() {
      amountToRemoveDouble = toRemove;
      amountToRemove = (toRemove * 100000000).round();
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
              )),
          ElevatedButton(
            child: Text(S.of(context).dex_add_max),
            onPressed: () {
              calculateMaxToPayback();
            },
          )
        ]),
        Padding(
            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10),
            child: WalletReturnAddressWidget(
              onChanged: (v) {
                setState(() {
                  _returnAddress = v;
                });
              },
            )),
        if (amountToRemove > availableBalance)
          AlertWidget(
            S.of(context).loan_payback_loan_insufficient_funds,
            color: Colors.red,
            alert: Alert.error,
          ),
        if (percentage > 0)
          ElevatedButton(
            child: Text(S.of(context).loan_payback),
            onPressed: availableBalance >= amountToRemove
                ? () async {
                    await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                      await doPaybakLoan();
                    });
                  }
                : null,
          )
      ])
    ]);
  }

  buildAmount() {
    var pricePerToken = widget.loanAmount.activePrice != null ? widget.loanAmount.activePrice.active.amount : 0.0;

    if (widget.loanAmount.symbolKey == "DUSD") {
      pricePerToken = 1.0;
    }

    var totalAmount = pricePerToken * totalVaultValue;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Row(children: <Widget>[TokenIcon(widget.loanAmount.symbol), Container(width: 5), Text(widget.loanAmount.displaySymbol)]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_borrowed_tokens, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_interest_amount + ' (${widget.loanVault.schema.interestRate} %)', style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [
                  Text(FundFormatter.format(totalVaultValue)),
                  Text(FundFormatter.format(totalVaultValue * double.tryParse(widget.loanVault.schema.interestRate) / 100, fractions: 4))
                ]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [
                  Text(S.of(context).loan_amount_payable, style: Theme.of(context).textTheme.caption),
                  Text(S.of(context).loan_price_per_token, style: Theme.of(context).textTheme.caption)
                ]),
                TableRow(children: [Text(FundFormatter.format(totalAmount, fractions: 2) + ' \$'), Text(FundFormatter.format(pricePerToken, fractions: 2) + ' \$')]),
              ]),
              Container(height: 10),
              Table(border: TableBorder(), children: [
                TableRow(children: [Text(S.of(context).loan_payback_available_balance, style: Theme.of(context).textTheme.caption)]),
                TableRow(children: [
                  Text(FundFormatter.format(availableBalance / DefiChainConstants.COIN)),
                ]),
              ])
            ])));
  }

  buildPayback() {
    var pricePerToken = widget.loanAmount.activePrice != null ? widget.loanAmount.activePrice.active.amount : 0.0;

    if (widget.loanAmount.symbolKey == "DUSD") {
      pricePerToken = 1.0;
    }

    return Card(
        child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Table(border: TableBorder(), children: [
                TableRow(children: [Text(S.of(context).loan_tokens_to_pay_back, style: Theme.of(context).textTheme.caption), Text(S.of(context).loan_payback_value)]),
                TableRow(children: [
                  Text(FundFormatter.format(amountToRemoveDouble)),
                  Text(FundFormatter.format((amountToRemoveDouble) * pricePerToken, fractions: 2) + " \$"),
                ]),
              ])
            ])));
  }

  @override
  Widget build(Object context) {
    if (!balanceLoaded) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_payback_title)),
          body: LoadingWidget(text: S.of(context).loading));
    }

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_payback_title)),
        body: Padding(padding: EdgeInsets.all(20), child: Column(children: [buildAmount(), buildPayback(), _buildRemove(context)])));
  }
}
