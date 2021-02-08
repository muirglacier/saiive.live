import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/pool_share.dart';

class PoolShareLiquidity extends PoolPair {
  final String tokenA;
  final String tokenB;
  final PoolPair poolPair;
  final PoolShare poolShare;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double poolSharePercentage;
  final double apy;

  PoolShareLiquidity({
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
