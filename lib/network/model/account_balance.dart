import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/helper/constants.dart';
import 'package:flutter/cupertino.dart';

class AccountBalance {
  final String token;
  int balance;
  bool isLPS = false;
  bool isDAT = false;

  ChainType chain;

  double get balanceDisplay => balance / DefiChainConstants.COIN;
  String get balanceDisplayRounded => (balance / DefiChainConstants.COIN).toStringAsFixed(8);

  AccountBalance({@required this.token, @required this.balance, @required this.chain});
}

class MixedAccountBalance extends AccountBalance
{
  int utxoBalance = 0;
  int tokenBalance = 0;

  double get utxoBalanceDisplay => utxoBalance / DefiChainConstants.COIN;
  String get utxoBalanceDisplayRounded => (utxoBalance / DefiChainConstants.COIN).toStringAsFixed(8);

  double get tokenBalanceDisplay => tokenBalance / DefiChainConstants.COIN;
  String get tokenBalanceDisplayRounded => (tokenBalance / DefiChainConstants.COIN).toStringAsFixed(8);

  MixedAccountBalance({String token, int balance, ChainType chain, this.utxoBalance, this.tokenBalance}): super(token: token, balance: balance, chain: chain);
}
