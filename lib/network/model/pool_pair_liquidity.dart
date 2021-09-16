import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/model/pool_share.dart';

class PoolPairLiquidity {
  final String tokenA;
  final String tokenB;
  final PoolPair poolPair;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double poolSharePercentage;
  final double apy;

  PoolPairLiquidity({
    this.tokenA,
    this.tokenB,
    this.poolPair,
    this.totalLiquidityInUSDT,
    this.yearlyPoolReward,
    this.poolSharePercentage,
    this.apy,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tokenA': tokenA,
    'tokenB': tokenB,
    'poolPair': poolPair.toJson(),
    'totalLiquidityInUSDT': totalLiquidityInUSDT,
    'yearlyPoolReward': yearlyPoolReward,
    'poolSharePercentage': poolSharePercentage,
    'apy': apy
  };
}
