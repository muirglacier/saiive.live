import 'dart:async';

import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/transaction_fail.dart';
import 'package:saiive.live/ui/utils/transaction_success.dart';
import 'package:saiive.live/ui/widgets/loading_overlay.dart';
import 'package:saiive.live/ui/widgets/table_widget.dart';
import 'package:wakelock/wakelock.dart';

class VaultBorrowLoanConfirmScreen extends StatefulWidget {
  final LoanVault loanVault;
  final LoanToken loanToken;
  final double amount;
  final String returnAddress;

  VaultBorrowLoanConfirmScreen(this.loanVault, this.loanToken, this.amount, this.returnAddress);

  @override
  State<StatefulWidget> createState() {
    return _VaultBorrowLoanConfirmScreen();
  }
}

class _VaultBorrowLoanConfirmScreen extends State<VaultBorrowLoanConfirmScreen> {
  double _collateralizationRatio = 0;
  double _totalTokenWithInterest = 0;
  double _totalInterestAmount = 0;
  double _totalInterest = 0;
  double _totalUSDValue = 0;
  double _interestToken = 0;
  double _interestVault = 0;
  double _loanTokenPriceUSD = 0;

  @override
  void initState() {
    super.initState();

    _interestToken = double.tryParse(widget.loanToken.interest);
    _interestVault = double.tryParse(widget.loanVault.schema.interestRate);

    _totalInterest = _interestVault + _interestToken;
    _totalInterestAmount = (widget.amount * _totalInterest / 100);
    _totalTokenWithInterest = widget.amount + _totalInterestAmount;

    _loanTokenPriceUSD = widget.loanToken.activePrice != null ? widget.loanToken.activePrice.active.amount : 0;

    _totalUSDValue = _totalTokenWithInterest * _loanTokenPriceUSD + double.tryParse(widget.loanVault.loanValue);
    _collateralizationRatio = (100 / _totalUSDValue) * double.tryParse(widget.loanVault.collateralValue);
  }

  Widget buildTopPart() {
    return Column(children: [
      Card(
          child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'You are borrowing',
            style: Theme.of(context).textTheme.caption,
          ),
          Row(children: [
            Text(
              FundFormatter.format(widget.amount),
              style: Theme.of(context).textTheme.headline3,
            ),
            Container(width: 5),
            Text(
              widget.loanToken.token.symbol,
              style: Theme.of(context).textTheme.caption,
            )
          ]),
        ]),
      ))
    ]);
  }

  buildTXDetails() {
    List<List<String>> items = [
      ['Loan Tokens to Borrow', FundFormatter.format(widget.amount) + ' ' + widget.loanToken.token.symbol],
      ['Token interest', _interestToken.toStringAsFixed(2) + '%'],
      ['Vault interest', _interestVault.toStringAsFixed(2) + '%'],
      ['Total Interest Amount', FundFormatter.format(_totalInterestAmount) + ' ' + widget.loanToken.token.symbol],
      ['Total Loan + interest', FundFormatter.format(_totalTokenWithInterest) + ' ' + widget.loanToken.token.symbol],
      ['Total Loan USD', FundFormatter.format(_totalUSDValue, fractions: 2) + ' \$'],
    ];

    return CustomTableWidget(items);
  }

  buildVaultDetails() {
    List<List<String>> items = [
      ['Vault ID', widget.loanVault.vaultId],
      ['Collateral Amount', FundFormatter.format(double.tryParse(widget.loanVault.collateralValue), fractions: 2) + ' \$'],
      ['Collateralization Ratio', widget.loanVault.collateralRatio + '%'],
    ];

    return CustomTableWidget(items);
  }

  buildResultDetails() {
    List<List<String>> items = [
      ['Resulting collateral Ratio', _collateralizationRatio.toStringAsFixed(2) + '%'],
    ];

    return CustomTableWidget(items);
  }

  doBorrowLoan() async {
    Wakelock.enable();

    final wallet = sl.get<DeFiChainWallet>();

    try {
      var streamController = StreamController<String>();
      var createVault = wallet.borrowLoan(widget.loanVault.vaultId, widget.loanVault.ownerAddress, widget.loanToken.token.symbolKey, (widget.amount * 100000000).round(),
          returnAddress: widget.returnAddress, loadingStream: streamController);

      final overlay = LoadingOverlay.of(context, loadingText: streamController.stream);
      var tx = await overlay.during(createVault);

      streamController.close();

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionSuccessScreen(ChainType.DeFiChain, tx, "Borrow successfull!"),
      ));

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TransactionFailScreen(S.of(context).wallet_operation_failed, ChainType.DeFiChain, error: e),
      ));
    } finally {
      Wakelock.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(toolbarHeight: StateContainer.of(context).curTheme.toolbarHeight, title: Text('Borrow Loan Token Confirm')),
        body: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: buildTopPart()),
              SliverToBoxAdapter(child: Container(height: 5)),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Transaction Details', style: Theme.of(context).textTheme.caption))),
              SliverToBoxAdapter(child: buildTXDetails()),
              SliverToBoxAdapter(child: Container(height: 5)),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Vault Details', style: Theme.of(context).textTheme.caption))),
              SliverToBoxAdapter(child: buildVaultDetails()),
              SliverToBoxAdapter(child: Container(height: 5)),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('Transcation Results', style: Theme.of(context).textTheme.caption))),
              SliverToBoxAdapter(child: buildResultDetails()),
              SliverToBoxAdapter(
                  child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          child: Text('Confirm Borrow'),
                          onPressed: () async {
                            await sl.get<AuthenticationHelper>().forceAuth(context, () async {
                              await doBorrowLoan();
                            });
                          }))),
              SliverToBoxAdapter(child: Container(height: 40)),
            ])));
  }
}
