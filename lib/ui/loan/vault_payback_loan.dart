import 'dart:async';

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
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/LoanHelper.dart';
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

  final CurrencyEnum currency;
  final double tetherPrice;

  VaultPaybackLoanScreen(this.loanAmount, this.loanToken, this.loanVault, this.loanInterest, this.currency, this.tetherPrice);

  @override
  State<StatefulWidget> createState() {
    return _VaultPaybackLoanScreen();
  }
}

class _VaultPaybackLoanScreen extends State<VaultPaybackLoanScreen> {
  int amountToRemove = 0;
  double amountToRemoveDouble = 0.0;
  int availableBalance = 0;
  int availableDFIBalance = 0;
  bool balanceLoaded = false;
  bool loanTokenLoaded = false;
  var _amountTextController = TextEditingController();
  bool isDUSDLoan = false;
  var paymentSelection;
  bool isDFIPayment = false;
  LoanCollateral dfiToken;
  double priceInDFI = 0;
  double priceInDFIPenalty = 0;
  double priceInDFIToPay = 0;
  int paymentTokenAmountToPayback = 0;

  double totalVaultValue = 0.0;
  int totalVaultValueSat = 0;
  String _returnAddress;

  @override
  void initState() {
    super.initState();

    isDUSDLoan = widget.loanAmount.symbolKey == "DUSD";
    paymentSelection = widget.loanAmount.symbolKey;
    totalVaultValue = double.parse(widget.loanAmount.amount);
    totalVaultValueSat = (totalVaultValue * 100000000).round();
    loadBalance();
    loadLoanToken();

    setState(() {
      amountToRemove = totalVaultValueSat;
      amountToRemoveDouble = totalVaultValue;
    });
    _amountTextController.text = amountToRemoveDouble.toString();
    _amountTextController.addListener(handleChange);
  }

  loadBalance() async {
    var balanceHelper = BalanceHelper();
    var accountBalance = await balanceHelper.getDisplayAccountBalance(spentable: true);

    var tokenBalance = accountBalance.firstWhere((element) => element.token == widget.loanAmount.symbol, orElse: () => null);
    var dfiTokenBalance = accountBalance.firstWhere((element) => element.token == 'DFI', orElse: () => null);

    setState(() {
      balanceLoaded = true;
      availableBalance = tokenBalance != null ? tokenBalance.balance : 0;
      availableDFIBalance = dfiTokenBalance != null ? dfiTokenBalance.balance : 0;
    });
  }

  loadLoanToken() async {
    if (isDUSDLoan) {
      var token = await sl<ILoansService>().getLoanCollateral(DeFiConstants.DefiAccountSymbol, 'DFI');

      setState(() {
        loanTokenLoaded = true;
        dfiToken = token;
      });

      calculatePaymentValueDFI();
    } else {
      setState(() {
        loanTokenLoaded = true;
      });
    }
  }

  doPaybakLoan() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    var streamController = StreamController<String>();
    try {
      var paybackToken = widget.loanToken.token.symbolKey;
      if (isDFIPayment) {
        paybackToken = DeFiConstants.DefiAccountSymbol;
      }
      var paybackLoan =
          wallet.paybackLoan(widget.loanVault.vaultId, widget.loanVault.ownerAddress, paybackToken, paymentTokenAmountToPayback, returnAddress: _returnAddress, loadingStream: streamController);

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
    _amountTextController.text = totalVaultValue.toString();

    handleChange();
  }

  handleChange() {
    double amount = double.tryParse(_amountTextController.text.replaceAll(',', '.'));

    if (amount == null) {
      return;
    }

    setState(() {
      amountToRemoveDouble = amount;
      amountToRemove = (amount * 100000000).round();
    });

    calculatePaymentValueDFI();

    if (isDFIPayment) {
      setState(() {
        paymentTokenAmountToPayback = (priceInDFIToPay * 100000000).round();
      });
    }
    else {
      setState(() {
        paymentTokenAmountToPayback = amountToRemove;
      });
    }
  }

  calculatePaymentValueDFI() {
    var penaltyDfiPrice =dfiToken.activePrice.active.amount * (1 - 0.01);

    setState(() {
      priceInDFI = double.parse((amountToRemoveDouble / dfiToken.activePrice.active.amount).toStringAsFixed(8));
      priceInDFIToPay = double.parse((amountToRemoveDouble / penaltyDfiPrice).toStringAsFixed(8));
      priceInDFIPenalty = priceInDFIToPay - priceInDFI;
    });

  }

  Widget _buildRemove(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Column(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                decoration: InputDecoration(labelText: '', counterText: '', suffix: Text(widget.loanAmount.symbolKey)),
                controller: _amountTextController),
          ),
          Container(width: 10),
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
        if (paymentTokenAmountToPayback > (isDFIPayment ? availableDFIBalance : availableBalance))
          AlertWidget(
            S.of(context).loan_payback_loan_insufficient_funds,
            color: Colors.red,
            alert: Alert.error,
          ),
        if (paymentTokenAmountToPayback > 0)
          ElevatedButton(
            child: Text(S.of(context).loan_payback),
            onPressed: (isDFIPayment ? availableDFIBalance : availableBalance) >= paymentTokenAmountToPayback
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
    var pricePerToken = LoanHelper.activePrice(widget.loanAmount.amount, widget.loanAmount.activePrice);

    if (isDUSDLoan) {
      pricePerToken = 1.0;
    }

    var totalAmount = pricePerToken * totalVaultValue;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
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
                TableRow(children: [
                  Text(FundFormatter.format(totalAmount * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency)),
                  Text(FundFormatter.format(pricePerToken * widget.tetherPrice, fractions: 2) + ' ' + Currency.getCurrencySymbol(widget.currency))
                ]),
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
    var pricePerToken = LoanHelper.activePrice(widget.loanAmount.amount, widget.loanAmount.activePrice);

    if (isDUSDLoan) {
      pricePerToken = 1.0;
    }

    if (isDFIPayment) {
      return Card(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Table(border: TableBorder(), children: [
                  TableRow(children: [Text(S.of(context).loan_tokens_to_pay_back, style: Theme.of(context).textTheme.caption), Text(S.of(context).loan_payback_value)]),
                  TableRow(children: [
                    Text(FundFormatter.format(amountToRemoveDouble)),
                    Text(FundFormatter.format((amountToRemoveDouble) * pricePerToken * widget.tetherPrice, fractions: 2) + " " + Currency.getCurrencySymbol(widget.currency)),
                  ]),
                ]),
                Container(height: 10),
                Table(border: TableBorder(), children: [
                  TableRow(children: [Text(S.of(context).loan_payback_dfi_value_in_usd, style: Theme.of(context).textTheme.caption),
                    Text(S.of(context).loan_payback_loan_value_in_dfi, style: Theme.of(context).textTheme.caption)]),
                  TableRow(children: [
                    Text(FundFormatter.format(dfiToken.activePrice.active.amount, fractions: 2) + " \$"),
                    Text(FundFormatter.format(priceInDFI, fractions: 8) + " DFI"),
                  ]),
                ]),
                Container(height: 10),
                Table(border: TableBorder(), children: [
                  TableRow(children: [Text(S.of(context).loan_payback_dfi_penalty, style: Theme.of(context).textTheme.caption), Text(S.of(context).loan_payback_dfi_to_pay, style: Theme.of(context).textTheme.caption)]),
                  TableRow(children: [
                    Text(FundFormatter.format(priceInDFIPenalty, fractions: 8) + " DFI"),
                    Text(FundFormatter.format(priceInDFIToPay, fractions: 8) + " DFI"),
                  ]),
                ])
              ])));
    }

    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Table(border: TableBorder(), children: [
                TableRow(children: [Text(S.of(context).loan_tokens_to_pay_back, style: Theme.of(context).textTheme.caption), Text(S.of(context).loan_payback_value)]),
                TableRow(children: [
                  Text(FundFormatter.format(amountToRemoveDouble)),
                  Text(FundFormatter.format((amountToRemoveDouble) * pricePerToken * widget.tetherPrice, fractions: 2) + " " + Currency.getCurrencySymbol(widget.currency)),
                ]),
              ])
            ])));
  }

  buildPaymentSelection() {
    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              DropdownButton<String>(
                isExpanded: true,
                value: paymentSelection,
                onChanged: (e) async {
                  setState(() {
                    paymentSelection = e;
                    isDFIPayment = paymentSelection == 'DFI';
                  });
                },
                items: ['DUSD', 'DFI'].map((e) {
                  return new DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
              ),
              if (isDFIPayment) Text(S.of(context).loan_payback_dfi_fee),
            ])));
  }

  @override
  Widget build(Object context) {
    if (!balanceLoaded || !loanTokenLoaded) {
      return Scaffold(
          appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_payback_title)),
          body: LoadingWidget(text: S.of(context).loading));
    }

    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text(S.of(context).loan_payback_title)),
        body: PrimaryScrollController(
            controller: new ScrollController(),
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(10), child: Column(children: [buildAmount(), buildPayback(), if (isDUSDLoan) buildPaymentSelection(), _buildRemove(context)])))));
  }
}
