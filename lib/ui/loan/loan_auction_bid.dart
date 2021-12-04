import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:flutter/material.dart';

class VaultAuctionBidScreen extends StatefulWidget {
  final LoanVaultAuction auction;
  final LoanVaultAuctionBatch batch;
  final AccountBalance balance;
  final Function(double amount) onBid;

  VaultAuctionBidScreen(this.auction, this.batch, this.balance, this.onBid);

  @override
  State<StatefulWidget> createState() {
    return _VaultAuctionBidScreen();
  }
}

class _VaultAuctionBidScreen extends State<VaultAuctionBidScreen> {
  var _amountController = TextEditingController(text: '');
  double _amount = 0;
  double _minBid = 0;
  bool _valid = true;

  @override
  void initState() {
    super.initState();

    _minBid = getMinBid();

    _amountController.addListener(handleChange);
    _amountController.text = _minBid.toString();
  }

  getMinBid() {
    var minBid = double.tryParse(widget.batch.loan.amount) * 1.05;

    if (widget.batch.highestBid != null) {
      minBid = double.tryParse(widget.batch.highestBid.amount.amount) * 1.01;
    }

    return minBid;
  }

  handleChange() async {
    double amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    bool valid = true;

    if (null == amount) {
      valid = false;
      return;
    }

    if (amount > widget.balance.balanceDisplay) {
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
                        hintText: 'How much you want to bid?',
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  Container(height: 10),
                  Row(children: [
                    Text('Available:'),
                    Expanded(child:
                      Text(widget.balance != null ? FundFormatter.format(widget.balance.balanceDisplay) : '0', textAlign: TextAlign.right)
                    ),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text('Bid has to be min:'),
                    Expanded(child: Text(FundFormatter.format(_minBid) + '@' + widget.batch.loan.symbol, textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text('Highest Bid:'),
                    Expanded(child: Text(widget.batch.highestBid != null ? FundFormatter.format(double.tryParse(widget.batch.highestBid.amount.amount)) + '@' + widget.batch.loan.symbol : 'N/A', textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text('Min Bid:'),
                    Expanded(child: Text(FundFormatter.format(double.tryParse(widget.batch.loan.amount)) + '@' + widget.batch.loan.symbol, textAlign: TextAlign.right)),
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Create Bid'),
                        onPressed: _amount == null || _amount == 0
                            ? null
                            : () {
                          this.widget.onBid(_amount);
                        },
                      )),
                  Container(height: 10),
                  if (!_valid) Text(S.of(context).loan_add_collateral_insufficient_funds)
                ]))));
  }
}

