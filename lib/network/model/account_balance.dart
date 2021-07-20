import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:flutter/cupertino.dart';

class AccountBalance {
  final String token;
  int balance;
  bool isLPS = false;
  bool isDAT = false;

  ChainType chain;

  double get balanceDisplay => balance / DefiChainConstants.COIN;

  bool get isNativeToken {
    if (DeFiConstants.isDfiToken(token)) {
      return true;
    }
    if (chain == ChainType.Bitcoin) {
      return true;
    }
    return false;
  }

  String get tokenDisplay {
    if (chain == ChainType.Bitcoin) {
      return "BTC";
    }

    if (isDAT && !isLPS) return "d" + token;
    return this.token;
  }

  String get additionalDisplay {
    if (chain == ChainType.Bitcoin) {
      return "Bitcoin";
    }
    if (isLPS || isDAT) {
      return isLPS ? "LP" : "DST";
    }

    if (!isLPS && !isDAT) {
      return 'Token';
    }

    return null;
  }

  AccountBalance({@required this.token, @required this.balance, @required this.chain});
}

class MixedAccountBalance extends AccountBalance {
  int utxoBalance = 0;
  int tokenBalance = 0;

  int get totalBalance => utxoBalance + tokenBalance;

  double get utxoBalanceDisplay => utxoBalance / DefiChainConstants.COIN;
  double get tokenBalanceDisplay => tokenBalance / DefiChainConstants.COIN;

  MixedAccountBalance({String token, int balance, ChainType chain, this.utxoBalance, this.tokenBalance}) : super(token: token, balance: balance, chain: chain);
}
