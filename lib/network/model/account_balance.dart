import 'package:defichainwallet/helper/constants.dart';

class AccountBalance {
  final String token;
  int balance;

  double get balanceDisplay => balance / DefiChainConstants.COIN;
  String get balanceDisplayRounded => (balance / DefiChainConstants.COIN).toStringAsFixed(8);

  AccountBalance({this.token, this.balance});
}
