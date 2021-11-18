import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/ui/loan/vault_borrow_loan.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';

class VaultTokenBoxWidget extends StatefulWidget {
  final LoanToken token;

  VaultTokenBoxWidget(this.token);

  @override
  State<StatefulWidget> createState() {
    return _VaultTokenBoxWidget();
  }
}

class _VaultTokenBoxWidget extends State<VaultTokenBoxWidget> {
  @override
  Widget build(Object context) {
    return InkWell(
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  VaultBorrowLoan(widget.token)));
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(children: [
                  Row(children: <Widget>[
                    Container(decoration: BoxDecoration(color: Colors.transparent), child: TokenIcon(widget.token.token.symbolKey)),
                    Container(width: 10),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        widget.token.token.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline6,
                      )
                    ])),
                  ]),
                  Container(height: 10),
                  Table(border: TableBorder(), children: [
                    TableRow(children: [Text('Interest', style: Theme.of(context).textTheme.caption), Text('Price (USD)', style: Theme.of(context).textTheme.caption)]),
                    TableRow(children: [
                      Text(widget.token.interest),
                      Text('?'),
                    ]),
                  ]),
                ]))));
  }
}
