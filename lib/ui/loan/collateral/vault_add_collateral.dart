import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/ui/loan/collateral/vault_add_collateral_amount.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:saiive.live/ui/widgets/auto_resize_text.dart';
import 'package:flutter/material.dart';

class VaultAddCollateralTokenScreen extends StatefulWidget {
  final List<AccountBalance> accountBalance;
  final Map<String,double> addedAmounts;
  final Function(AccountBalance token, double amount) onCollateralChanged;

  VaultAddCollateralTokenScreen(this.accountBalance, this.addedAmounts, this.onCollateralChanged);

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
                    final account = widget.accountBalance.elementAt(index);
                    return _buildAccountEntry(account);
                  },
                  childCount: widget.accountBalance.length,
                ),
              )
            ]));
  }

  Widget _buildAccountEntry(AccountBalance balance) {
    return Card(
        child: ListTile(
          leading: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TokenIcon(balance.token)]),
          title: Column(children: [
            Row(children: [
              Text(
                balance.token,
                style: Theme.of(context).textTheme.headline3,
              ),
              Expanded(
                  child: AutoSizeText(
                    FundFormatter.format(balance.balanceDisplay),
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                  )),
            ])
          ]),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => VaultAddCollateralAmountScreen(
                    balance, widget.addedAmounts.containsKey(balance.token) ? widget.addedAmounts[balance.token] : 0,
                        (amount) =>
                    {this.widget.onCollateralChanged(balance, amount)})));
          },
        ));
  }
}

