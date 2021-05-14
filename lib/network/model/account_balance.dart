import 'package:defichainwallet/helper/constants.dart';

class AccountBalance {
  final String token;
  int balance;
  bool isLPS = false;
  bool isDAT = false;

  double get balanceDisplay => balance / DefiChainConstants.COIN;
  String get balanceDisplayRounded => (balance / DefiChainConstants.COIN).toStringAsFixed(8);

  AccountBalance({this.token, this.balance});
}

class MixedAccountBalance extends AccountBalance
{
  int utxoBalance = 0;
  int tokenBalance = 0;

  double get utxoBalanceDisplay => utxoBalance / DefiChainConstants.COIN;
  String get utxoBalanceDisplayRounded => (utxoBalance / DefiChainConstants.COIN).toStringAsFixed(8);

  double get tokenBalanceDisplay => tokenBalance / DefiChainConstants.COIN;
  String get tokenBalanceDisplayRounded => (tokenBalance / DefiChainConstants.COIN).toStringAsFixed(8);

  MixedAccountBalance({String token, int balance, this.utxoBalance, this.tokenBalance}): super(token: token, balance: balance);
}
