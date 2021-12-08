import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/widgets/wallet_return_address_widget.dart';

class VaultAuctionBidScreen extends StatefulWidget {
  final LoanVaultAuction auction;
  final LoanVaultAuctionBatch batch;
  final AccountBalance balance;
  final Function(double amount, String from) onBid;

  VaultAuctionBidScreen(this.auction, this.batch, this.balance, this.onBid);

  @override
  State<StatefulWidget> createState() {
    return _VaultAuctionBidScreen();
  }
}

class _VaultAuctionBidScreen extends State<VaultAuctionBidScreen> {
  var _amountController = TextEditingController(text: '');
  double _amount = 0;
  bool _valid = true;

  String _from;

  @override
  void initState() {
    super.initState();

    _amountController.addListener(handleChange);
    _amountController.text = widget.batch.minBid.toString();
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
                        hintText: S.of(context).loan_auction_bid_how_much,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  Container(height: 10),
                  WalletReturnAddressWidget(
                    expanded: false,
                    title: S.of(context).loan_auction_bid_from,
                    checkBoxText: S.of(context).loan_auction_bid_from_text,
                    onChanged: (v) {
                      setState(() {
                        _from = v;
                      });
                    },
                  ),
                  Container(height: 10),
                  Row(children: [
                    Text(S.of(context).loan_auction_bid_available_balance),
                    Expanded(child: Text(widget.balance != null ? FundFormatter.format(widget.balance.balanceDisplay) : '0', textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Expanded(child: Text((widget.balance != null ? FundFormatter.format(widget.balance.balanceDisplay * (widget.batch.loan.activePrice != null ? widget.batch.loan.activePrice.active.amount : 1), fractions: 2) : '0') + ' \$', textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text(S.of(context).loan_auction_min_bid_has_to_be),
                    Expanded(child: Text(FundFormatter.format(widget.batch.minBid) + '@' + widget.batch.loan.symbol, textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Expanded(child: Text(FundFormatter.format(widget.batch.minBidUSD, fractions: 2) + ' \$', textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text(S.of(context).loan_auction_highest_bid),
                    Expanded(
                        child: Text(
                            widget.batch.highestBid != null ? FundFormatter.format(double.tryParse(widget.batch.highestBid.amount.amount)) + '@' + widget.batch.loan.symbol : 'N/A',
                            textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Expanded(
                        child: Text(
                            widget.batch.highestBid != null ? (FundFormatter.format(widget.batch.highestBid.amount.valueUSD, fractions: 2) + ' \$') : 'N/A',
                            textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Text(S.of(context).loan_auction_min_bid),
                    Expanded(child: Text(FundFormatter.format(double.tryParse(widget.batch.loan.amount)) + '@' + widget.batch.loan.symbol, textAlign: TextAlign.right)),
                  ]),
                  Container(height: 5),
                  Row(children: [
                    Expanded(child: Text(FundFormatter.format(widget.batch.loan.valueUSD, fractions: 2) + ' \$', textAlign: TextAlign.right)),
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text(S.of(context).loan_auction_create_bid),
                        onPressed: _amount == null || _amount == 0
                            ? null
                            : () {
                                this.widget.onBid(_amount, _from);
                              },
                      )),
                  Container(height: 10),
                  if (!_valid) Text(S.of(context).loan_add_collateral_insufficient_funds)
                ]))));
  }
}
