import 'package:defichainwallet/ui/utils/token_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TokenPairIcon extends StatefulWidget {
  String _tokenA;
  String _tokenB;

  TokenPairIcon(this._tokenA, this._tokenB);

  @override
  _TokenPairIconState createState() =>
      new _TokenPairIconState(this._tokenA, this._tokenB);
}

class _TokenPairIconState extends State<TokenPairIcon> {
  String _tokenA;
  String _tokenB;

  _TokenPairIconState(this._tokenA, this._tokenB);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 64,
          child: Stack(
            children: <Widget>[
              TokenIcon(_tokenA),
              Positioned(
                left: 20,
                child: TokenIcon(_tokenB),
              )
            ],
          )),
      Text(_tokenA + ' - ' + _tokenB, textAlign: TextAlign.left)
    ]);
  }
}
