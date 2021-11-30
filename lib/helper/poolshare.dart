import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/coingecko_service.dart';
import 'package:saiive.live/network/gov_service.dart';
import 'package:saiive.live/network/model/pool_share.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';
import 'package:saiive.live/network/model/yield_farming.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/network/pool_share_service.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';

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
    var poolStats = new Map<String, YieldFarming>();
    var priceData = await sl.get<ICoingeckoService>().getCoins(coin, currency);

    var combinedPoolShares = new Map<String, PoolShare>();

    for (var poolShare in poolShares) {
      if (!combinedPoolShares.containsKey(poolShare.poolID)) {
        combinedPoolShares[poolShare.poolID] = poolShare;
      } else {
        combinedPoolShares[poolShare.poolID].displayAmount += poolShare.displayAmount;
      }
    }

    List<PoolShareLiquidity> waitResult = [];
    var tokens = await sl.get<ITokenService>().getTokens(DeFiConstants.DefiAccountSymbol);
    Iterable<Future<PoolShareLiquidity>> result = combinedPoolShares.values.map((poolShare) async {
      var poolPair = await sl.get<IPoolPairService>().getPoolPair(coin, poolShare.poolID);
      var idTokenA = poolPair.idTokenA;
      var idTokenB = poolPair.idTokenB;
      var allPoolShares = poolShares.where((element) => element.poolID == poolShare.poolID).toList();

      var tokenA = tokens.singleWhere((element) => element.id.toString() == idTokenA);
      var tokenB = tokens.singleWhere((element) => element.id.toString() == idTokenB);

      var poolSharePercentage = (poolShare.displayAmount / poolShare.totalLiquidity) * 100;

      var dfiCoin = priceData.firstWhere((element) => element.idToken == '0', orElse: () => null);
      var priceA = priceData.firstWhere((element) => element.idToken == poolPair.idTokenA, orElse: () => null);
      var priceB = priceData.firstWhere((element) => element.idToken == poolPair.idTokenB, orElse: () => null);

      var yearlyPoolReward = lpDailyDfiReward * poolPair.rewardPct * 365 * (dfiCoin != null ? dfiCoin.fiat : 0);

      double customRewardDFI = 0;
      double blockCommissionDFI = 0;

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
      } else {
        blockCommissionDFI = poolPair.blockCommissionB;
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

      var blockRewardFiat = blockReward * (dfiCoin != null ? dfiCoin.fiat : 0.0);
      var minuteRewardFiat = minuteReward * (dfiCoin != null ? dfiCoin.fiat : 0.0);
      var hourlyRewordFiat = hourlyReword * (dfiCoin != null ? dfiCoin.fiat : 0.0);
      var dailyRewardFiat = dailyReward * (dfiCoin != null ? dfiCoin.fiat : 0.0);
      var yearlyRewardFiat = yearlyReward * (dfiCoin != null ? dfiCoin.fiat : 0.0);

      var liquidityReserveidTokenA = poolPair.reserveA * (priceA != null ? priceA.fiat : 0.0);
      var liquidityReserveidTokenB = poolPair.reserveB * (priceB != null ? priceB.fiat : 0.0);
      var totalLiquidity = liquidityReserveidTokenA + liquidityReserveidTokenB;
      var apy = poolStats.containsKey(idTokenA + '_' + idTokenB) ? poolStats[idTokenA + '_' + idTokenB].apy : 0.0;

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
