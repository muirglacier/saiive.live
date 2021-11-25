import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/ui/loan/collateral/vault_add_collateral_amount.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:flutter/material.dart';

class VaultAddCollateralTokenScreen extends StatefulWidget {
  final List<AccountBalance> accountBalance;
  final List<LoanCollateral> collateralTokens;
  final Map<String,double> addedAmounts;
  final Function(LoanCollateral loanToken, double amount) onCollateralChanged;

  VaultAddCollateralTokenScreen(this.accountBalance, this.collateralTokens, this.addedAmounts, this.onCollateralChanged);

  @override
  State<StatefulWidget> createState() {
    return _VaultAddCollateralTokenScreen();
  }
}

class _VaultAddCollateralTokenScreen
    extends State<VaultAddCollateralTokenScreen> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    final account = widget.collateralTokens.elementAt(index);
                    return _buildAccountEntry(account);
                  },
                  childCount: widget.collateralTokens.length,
                ),
              )
            ]));
  }

  Widget _buildAccountEntry(LoanCollateral loanCollateral) {
    var balance = widget.accountBalance.firstWhere((element) => element.token == loanCollateral.token.symbol, orElse: () => null);

    return Card(
        child: ListTile(
          leading: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TokenIcon(loanCollateral.token.symbol)]),
          title: Column(children: [
            Row(children: [
              Text(
                loanCollateral.token.symbol,
                style: Theme.of(context).textTheme.headline3,
              ),
              Expanded(
                  child: AutoSizeText(
                    balance != null ? FundFormatter.format(balance.balanceDisplay) : '0',
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                  )),
            ])
          ]),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => VaultAddCollateralAmountScreen(
                    balance, widget.addedAmounts.containsKey(loanCollateral.token.symbol) ? widget.addedAmounts[loanCollateral.token.symbol] : 0,
                        (amount) =>
                    {this.widget.onCollateralChanged(loanCollateral, amount)})));
          },
        ));
  }
}

