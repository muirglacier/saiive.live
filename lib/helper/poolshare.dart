import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/coingecko_service.dart';
import 'package:saiive.live/network/gov_service.dart';
import 'package:saiive.live/network/model/pool_share.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/network/pool_share_service.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class PoolShareHelper {
  Future<List<PoolShareLiquidity>> getPoolShares(String coin, String currency, Stats stats) async {
    var poolShares = await sl.get<IPoolShareService>().getPoolShares(coin);

    return handleFetchPoolShares(coin, currency, stats, poolShares);
  }

  Future<List<PoolShareLiquidity>> getMyPoolShares(String coin, String currency, Stats stats) async {
    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys(onlyActive: true);
    var poolShares = await sl.get<IPoolShareService>().getMyPoolShare(coin, pubKeyList);

    return handleFetchPoolShares(coin, currency, stats, poolShares);
  }

  Future<List<PoolShareLiquidity>> handleFetchPoolShares(String coin, String currency, Stats stats, List<PoolShare> poolShares) async {
    final chainNet = await sl.get<ISharedPrefsUtil>().getChainNetwork();
    var blockRewardsDex = stats.dexRewards(chainNet);
    var blockRewardsStockToken = stats.tokenRewards(chainNet);

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
      var stockShares = {
        "17": 0.5,
        "18": 0.1098,
        "25": 0.0499,
        "32": 0.0239,
        "33": 0.0335,
        "35": 0.0263,
        "36": 0.0378,
        "38": 0.0786,
        "39": 0.0479,
        "40": 0.0107,
        "41": 0.0096,
        "42": 0.0222,
        "43": 0.0108,
        "44": 0.008,
        "45": 0.0144,
        "46": 0.0166
      };

      var isStockPair = (tokenA.symbolKey == 'DUSD' || tokenB.symbolKey == 'DUSD');
      var subsidyPerBlock = isStockPair ? blockRewardsStockToken : blockRewardsDex;
      var poolSharePercentage = (poolShare.displayAmount / poolShare.totalLiquidity) * 100;

      var dfiCoin = priceData.firstWhere((element) => element.idToken == '0', orElse: () => null);
      var yearlyPoolReward = (subsidyPerBlock * 2 * 60 * 24) * poolPair.rewardPct * 365 * (dfiCoin != null ? dfiCoin.fiat : 0);

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
      var poolReward = subsidyPerBlock * poolPair.rewardPct;

      if (isStockPair && stockShares.containsKey(poolPair.id)) {
        poolReward = subsidyPerBlock * stockShares[poolPair.id];
      }

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

      return new PoolShareLiquidity(
          tokenA: tokenA.symbol,
          tokenB: tokenB.symbol,
          poolPair: poolPair,
          poolShare: poolShare,
          totalLiquidityInUSDT: poolPair.totalLiquidityUsd,
          yearlyPoolReward: yearlyPoolReward,
          poolSharePercentage: poolSharePercentage,
          apr: poolPair.apr,
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
