import 'package:flutter/cupertino.dart';

class TokenBalance {
  final String hash;
  final String idToken;
  final int balance;
  final bool isPopularToken;
  final String displayName;

  TokenBalance({this.hash, this.idToken, this.balance, this.isPopularToken, @required this.displayName});
}
