import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/coingecko_service.dart';
import 'package:defichainwallet/network/defichain_service.dart';
import 'package:defichainwallet/network/gov_service.dart';
import 'package:defichainwallet/network/model/pool_share.dart';
import 'package:defichainwallet/network/model/pool_share_liquidity.dart';
import 'package:defichainwallet/network/model/yield_farming.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/network/pool_share_service.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/service_locator.dart';

class PoolShareHelper {
  Future<List<PoolShareLiquidity>> getPoolShares(String coin, String currency) async {
    var poolShares = await sl.get<IPoolShareService>().getPoolShares(coin);

    return handleFetchPoolShares(coin, currency, poolShares);
  }

  Future<List<PoolShareLiquidity>> getMyPoolShares(String coin, String currency) async {
    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys();
    var poolShares = await sl.get<IPoolShareService>().getMyPoolShare(coin, pubKeyList);

    return handleFetchPoolShares(coin, currency, poolShares);
  }

  Future<List<PoolShareLiquidity>> handleFetchPoolShares(String coin, String currency, List<PoolShare> poolShares) async {
    var gov = await sl.get<IGovService>().getGov(coin);
    var lpDailyDfiReward = gov['LP_DAILY_DFI_REWARD'];
    var poolStatsTmp = await sl.get<IDefichainService>().getStatsYieldFarming(coin);
    var poolStats = new Map<String, YieldFarming>();
    var priceData = await sl.get<ICoingeckoService>().getCoins(coin, currency);

    poolStatsTmp.forEach((value) {
      poolStats[value.idTokenA + '_' + value.idTokenB] = value;
    });

    var combinedPoolShares = new Map<String, PoolShare>();

    for (var poolShare in poolShares) {
      if (!combinedPoolShares.containsKey(poolShare.poolID)) {
        combinedPoolShares[poolShare.poolID] = poolShare;
      } else {
        combinedPoolShares[poolShare.poolID].amount += poolShare.amount;
      }
    }

    List<PoolShareLiquidity> waitResult = [];
    Iterable<Future<PoolShareLiquidity>> result = combinedPoolShares.values.map((poolShare) async {
      var poolPair = await sl.get<IPoolPairService>().getPoolPair(coin, poolShare.poolID);
      var idTokenA = poolPair.idTokenA;
      var idTokenB = poolPair.idTokenB;
      var allPoolShares = poolShares.where((element) => element.poolID == poolShare.poolID).toList();

      var tokenA = await sl.get<ITokenService>().getToken(coin, idTokenA);
      var tokenB = await sl.get<ITokenService>().getToken(coin, idTokenB);

      var poolSharePercentage = (poolShare.amount / poolShare.totalLiquidity) * 100;

      var dfiCoin = priceData.firstWhere((element) => element.idToken == '0', orElse: () => null);
      var priceA = priceData.firstWhere((element) => element.idToken == poolPair.idTokenA, orElse: () => null);
      var priceB = priceData.firstWhere((element) => element.idToken == poolPair.idTokenB, orElse: () => null);

      var yearlyPoolReward = lpDailyDfiReward * poolPair.rewardPct * 365 * (dfiCoin != null ? dfiCoin.fiat : 0);

      double customRewardDFI = 0;
      double blockCommissionDFI = 0;
      double blockCommissionOther = 0;

      if (null != poolPair.customRewards) {
        poolPair.customRewards.forEach((e) {
          String idToken = e.split('@')[1];
          double reward = double.tryParse(e.split('@')[0]);

          if ('0' == idToken) {
            customRewardDFI += reward;
          }
        });
      }

      if (poolPair.idTokenA == '0') {
        blockCommissionDFI = poolPair.blockCommissionA;
        blockCommissionOther = poolPair.blockCommissionB;
      } else {
        blockCommissionDFI = poolPair.blockCommissionB;
        blockCommissionOther = poolPair.blockCommissionA;
      }

      //30 seconds is the block time
      var poolReward = (lpDailyDfiReward / ((24 * 60 * 60) / 30)) * poolPair.rewardPct;

      var customRewards = customRewardDFI * (poolSharePercentage / 100);
      var blockReward = poolReward * (poolSharePercentage / 100);
      var blockCommission = blockCommissionDFI * (poolSharePercentage / 100);

      var totalRewardsPerBlock = (blockReward + customRewards + blockCommission);

      var rewardPerBlock = totalRewardsPerBlock;
      var minuteReward = rewardPerBlock * 2;
      var hourlyReword = minuteReward * 60;
      var dailyReward = hourlyReword * 24;
      var yearlyReward = dailyReward * 365;

      var blockRewardFiat = blockReward * (dfiCoin != null ? dfiCoin.fiat : 0);
      var minuteRewardFiat = minuteReward * (dfiCoin != null ? dfiCoin.fiat : 0);
      var hourlyRewordFiat = hourlyReword * (dfiCoin != null ? dfiCoin.fiat : 0);
      var dailyRewardFiat = dailyReward * (dfiCoin != null ? dfiCoin.fiat : 0);
      var yearlyRewardFiat = yearlyReward * (dfiCoin != null ? dfiCoin.fiat : 0);

      var liquidityReserveidTokenA = poolPair.reserveA * (priceA != null ? priceA.fiat : 0);
      var liquidityReserveidTokenB = poolPair.reserveB * (priceB != null ? priceB.fiat : 0);
      var totalLiquidity = liquidityReserveidTokenA + liquidityReserveidTokenB;
      var apy = poolStats.containsKey(idTokenA + '_' + idTokenB) ? poolStats[idTokenA + '_' + idTokenB].apy : 0;

      return new PoolShareLiquidity(
          tokenA: tokenA.symbol,
          tokenB: tokenB.symbol,
          poolPair: poolPair,
          poolShare: poolShare,
          totalLiquidityInUSDT: totalLiquidity,
          yearlyPoolReward: yearlyPoolReward,
          poolSharePercentage: poolSharePercentage,
          apy: apy,
          coin: dfiCoin,
          blockReward: rewardPerBlock,
          minuteReward: minuteReward,
          hourlyReword: hourlyReword,
          dailyReward: dailyReward,
          yearlyReward: yearlyReward,
          blockRewardFiat: blockRewardFiat,
          minuteRewardFiat: minuteRewardFiat,
          hourlyRewordFiat: hourlyRewordFiat,
          dailyRewardFiat: dailyRewardFiat,
          yearlyRewardFiat: yearlyRewardFiat,
          poolShares: allPoolShares);
    });

    for (Future<PoolShareLiquidity> f in result) {
      waitResult.add(await f);
    }

    return waitResult;
  }
}
