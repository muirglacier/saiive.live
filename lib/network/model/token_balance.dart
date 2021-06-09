import 'package:saiive.live/helper/constants.dart';
import 'package:flutter/cupertino.dart';

class TokenBalance {
  final String hash;
  final String idToken;
  final int balance;
  final bool isPopularToken;
  final String displayName;

  String get balanceDisplayRounded => (balance / DefiChainConstants.COIN).toStringAsFixed(8);

  TokenBalance({this.hash, this.idToken, this.balance, this.isPopularToken, @required this.displayName});
}
