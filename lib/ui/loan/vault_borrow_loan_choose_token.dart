import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:flutter/material.dart';
import 'package:saiive.live/ui/utils/fund_formatter.dart';

class VaultBorrowLoanChooseTokenScreen extends StatefulWidget {
  final List<LoanToken> tokens;
  final Function(LoanToken vault) onTokenSelected;
  final key = GlobalKey();

  VaultBorrowLoanChooseTokenScreen(this.tokens, this.onTokenSelected);

  @override
  State<StatefulWidget> createState() {
    return _VaultBorrowLoanChooseTokenScreen();
  }
}

class _VaultBorrowLoanChooseTokenScreen extends State<VaultBorrowLoanChooseTokenScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: CustomScrollView(physics: BouncingScrollPhysics(), scrollDirection: Axis.vertical, slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final vault = widget.tokens.elementAt(index);
                return _buildTokenEntry(vault);
              },
              childCount: widget.tokens.length,
            ),
          )
        ]));
  }

  Widget _buildTokenEntry(LoanToken token) {
    var loanTokenPriceUSD = token.activePrice != null ? token.activePrice.active.amount : 0.0;

    if (token.token.symbolKey == "DUSD") {
      loanTokenPriceUSD = 1.0;
    }
    return Card(
        child: ListTile(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          token.token.name,
          overflow: TextOverflow.ellipsis,
        ),
        Row(children: [
          Text(
            S.of(context).loan_price_per_token,
            style: Theme.of(context).textTheme.caption,
          ),
          Container(width: 5),
          Text(FundFormatter.format(loanTokenPriceUSD, fractions: 2))
        ])
      ]),
      onTap: () {
        this.widget.onTokenSelected(token);
      },
    ));
  }
}
