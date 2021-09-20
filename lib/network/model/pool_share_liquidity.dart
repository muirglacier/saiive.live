import 'package:saiive.live/network/model/coin.dart';
import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/model/pool_share.dart';

class PoolShareLiquidity {
  final String tokenA;
  final String tokenB;
  final PoolPair poolPair;
  final PoolShare poolShare;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double poolSharePercentage;
  final double apy;
  final List<PoolShare> poolShares;

  final double blockReward;
  final double minuteReward;
  final double hourlyReword;
  final double dailyReward;
  final double yearlyReward;

  final double blockRewardFiat;
  final double minuteRewardFiat;
  final double hourlyRewordFiat;
  final double dailyRewardFiat;
  final double yearlyRewardFiat;

  final Coin coin;

  PoolShareLiquidity(
      {this.tokenA,
      this.tokenB,
      this.poolPair,
      this.poolShare,
      this.totalLiquidityInUSDT,
      this.yearlyPoolReward,
      this.poolSharePercentage,
      this.apy,
      this.coin,
      this.blockReward,
      this.minuteReward,
      this.hourlyReword,
      this.dailyReward,
      this.yearlyReward,
      this.blockRewardFiat,
      this.minuteRewardFiat,
      this.hourlyRewordFiat,
      this.dailyRewardFiat,
      this.yearlyRewardFiat,
      this.poolShares
    });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tokenA': tokenA,
    'tokenB': tokenB,
    'poolPair': poolPair.toJson(),
    'totalLiquidityInUSDT': totalLiquidityInUSDT,
    'yearlyPoolReward': yearlyPoolReward,
    'poolSharePercentage': poolSharePercentage,
    'apy': apy,
    'coin': coin.toJson(),
    'blockReward': blockReward,
    'minuteReward': minuteReward,
    'hourlyReword': hourlyReword,
    'dailyReward': dailyReward,
    'yearlyReward': yearlyReward,
    'blockRewardFiat': blockRewardFiat,
    'minuteRewardFiat': minuteRewardFiat,
    'hourlyRewordFiat': hourlyRewordFiat,
    'dailyRewardFiat': dailyRewardFiat,
    'yearlyRewardFiat': yearlyRewardFiat
  };
}
