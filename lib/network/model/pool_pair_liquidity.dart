import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/model/pool_share.dart';

class PoolPairLiquidity extends PoolPair {
  final String tokenA;
  final String tokenB;
  final PoolPair poolPair;
  final PoolShare poolShare;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double poolSharePercentage;
  final double apy;

  PoolPairLiquidity({
    this.tokenA,
    this.tokenB,
    this.poolPair,
    this.poolShare,
    this.totalLiquidityInUSDT,
    this.yearlyPoolReward,
    this.poolSharePercentage,
    this.apy,
  });
}
