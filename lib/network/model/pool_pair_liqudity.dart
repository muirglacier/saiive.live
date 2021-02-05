import 'package:defichainwallet/network/model/pool_pair.dart';

class PoolPairLiquidity extends PoolPair {
  final PoolPair poolPair;
  final double totalLiquidityInUSDT;
  final double yearlyPoolReward;
  final double apy;

  PoolPairLiquidity({
    this.poolPair,
    this.totalLiquidityInUSDT,
    this.yearlyPoolReward,
    this.apy,
  });
}
