import 'package:saiive.live/network/model/pool_pair.dart';

class PoolPairLiquidity {
  final String tokenA;
  final String tokenB;
  final PoolPair poolPair;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double poolSharePercentage;
  final double apr;

  PoolPairLiquidity({
    this.tokenA,
    this.tokenB,
    this.poolPair,
    this.totalLiquidityInUSDT,
    this.yearlyPoolReward,
    this.poolSharePercentage,
    this.apr,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tokenA': tokenA,
        'tokenB': tokenB,
        'poolPair': poolPair.toJson(),
        'totalLiquidityInUSDT': totalLiquidityInUSDT,
        'yearlyPoolReward': yearlyPoolReward,
        'poolSharePercentage': poolSharePercentage,
        'apr': apr
      };
}
