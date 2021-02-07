import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/coingecko_service.dart';
import 'package:defichainwallet/network/defichain_service.dart';
import 'package:defichainwallet/network/gov_service.dart';
import 'package:defichainwallet/network/model/pool_pair_liqudity.dart';
import 'package:defichainwallet/network/model/yield_farming.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/network/pool_share_service.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/service_locator.dart';

class PoolShareHelper {
  Future<List<PoolPairLiquidity>> getMyPoolShares(String coin, String currency) async {
    var gov = await sl.get<GovService>().getGov(coin);
    var lpDailyDfiReward = gov['LP_DAILY_DFI_REWARD'];
    var pubKeyList = await sl.get<DeFiChainWallet>().getPublicKeys();
    var poolShares = await sl.get<PoolShareService>().getMyPoolShare(coin, pubKeyList);
    var poolStatsTmp = await sl.get<DefichainService>().getStatsYieldFarming(coin);
    var poolStats = new Map<String, YieldFarming>();
    var priceData = await sl.get<CoingeckoService>().getCoins(coin, currency);

    poolStatsTmp.forEach((value) {
      poolStats[value.idTokenA + '_' + value.idTokenB] = value;
    });

    List<PoolPairLiquidity> waitResult = [];
    Iterable<Future<PoolPairLiquidity>> result = poolShares.map((poolShare) async {
      var poolPair = await sl.get<PoolPairService>().getPoolPair(coin, poolShare.poolID);
      var idTokenA = poolPair.idTokenA;
      var idTokenB = poolPair.idTokenB;

      var tokenA = await sl.get<TokenService>().getToken(coin, idTokenA);
      var tokenB = await sl.get<TokenService>().getToken(coin, idTokenB);

      var poolSharePercentage =
          (poolShare.amount / poolShare.totalLiquidity) * 100;

      var dfiCoin = priceData.firstWhere((element) => element.idToken == '0', orElse: () =>  null);
      var priceA = priceData.firstWhere((element) => element.idToken == poolPair.idTokenA, orElse: () =>  null);
      var priceB = priceData.firstWhere((element) => element.idToken == poolPair.idTokenB, orElse: () =>  null);

      var yearlyPoolReward = lpDailyDfiReward * poolPair.rewardPct * 365 * (dfiCoin != null ? dfiCoin.fiat : 0);

      var liquidityReserveidTokenA = poolPair.reserveA * (priceA != null ? priceA.fiat : 0);
      var liquidityReserveidTokenB = poolPair.reserveB * (priceB != null ? priceB.fiat : 0);
      var totalLiquidity = liquidityReserveidTokenA + liquidityReserveidTokenB;
      var apy = poolStats.containsKey(idTokenA + '_' + idTokenB) ? poolStats[idTokenA + '_' + idTokenB].apy : 0;

      return new PoolPairLiquidity(
        tokenA: tokenA.symbol,
        tokenB: tokenB.symbol,
        poolPair: poolPair,
        poolShare: poolShare,
        totalLiquidityInUSDT: totalLiquidity,
        yearlyPoolReward: yearlyPoolReward,
        poolSharePercentage: poolSharePercentage,
        apy: apy
      );
    });

    for(Future<PoolPairLiquidity> f in result) {
      waitResult.add(await f);
    }

    return waitResult;
  }
}
