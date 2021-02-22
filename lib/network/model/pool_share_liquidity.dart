import 'package:defichainwallet/network/model/coin.dart';
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
      this.yearlyRewardFiat});
}
