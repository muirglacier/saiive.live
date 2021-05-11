import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:flutter/cupertino.dart';

class AccountBalance {
  final String token;
  int balance;

  ChainType chain;

  double get balanceDisplay => balance / DefiChainConstants.COIN;
  String get balanceDisplayRounded => (balance / DefiChainConstants.COIN).toStringAsFixed(8);

  AccountBalance({@required this.token, @required this.balance});
}
