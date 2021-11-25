import 'dart:math';

import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';
import 'package:saiive.live/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TokenSetIcons extends StatefulWidget {
  final List<LoanVaultAmount> tokens;
  final int maxToDisplay;

  TokenSetIcons(this.tokens, this.maxToDisplay);

  @override
  _TokenSetIcons createState() => new _TokenSetIcons();
}

class _TokenSetIcons extends State<TokenSetIcons> {
  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];

    for (int i = 0; i < min(widget.maxToDisplay, widget.tokens.length); i++) {
      if (i == 0) {
        icons.add(TokenIcon(widget.tokens.elementAt(i).symbolKey));
      } else {
        icons.add(Positioned(
          height: 20,
          left: i.toDouble() * 10.0,
          child: TokenIcon(widget.tokens.elementAt(i).symbolKey),
        ));
      }
    }

    if (icons.length == 0) {
      return Container();
    }

    return Container(
        height: 20,
        child: Row(children: [
          Container(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: icons,
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
          ),
          if (widget.tokens.length > widget.maxToDisplay)
            Text('& ${widget.tokens.length - widget.maxToDisplay} more')
        ]));
  }
}
