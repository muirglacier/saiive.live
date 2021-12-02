import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/coingecko_service.dart';
import 'package:saiive.live/network/gov_service.dart';
import 'package:saiive.live/network/model/pool_pair_liquidity.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';

class PoolPairHelper {
  Future<List<PoolPairLiquidity>> getPoolPairs(String coin, String currency) async {
    var gov = await sl.get<IGovService>().getGov(coin);
    var lpDailyDfiReward = gov['LP_DAILY_DFI_REWARD'];
    var priceData = await sl.get<ICoingeckoService>().getCoins(coin, currency);
    var poolPairs = await sl.get<IPoolPairService>().getPoolPairs(coin);

    var tokens = await sl.get<ITokenService>().getTokens(DeFiConstants.DefiAccountSymbol);

    List<PoolPairLiquidity> waitResult = [];
    Iterable<Future<PoolPairLiquidity>> result = poolPairs.map((poolPair) async {
      var idTokenA = poolPair.idTokenA;
      var idTokenB = poolPair.idTokenB;

      var tokenA = tokens.singleWhere((element) => element.id.toString() == idTokenA);
      var tokenB = tokens.singleWhere((element) => element.id.toString() == idTokenB);

      var dfiCoin = priceData.firstWhere((element) => element.idToken == '0', orElse: () => null);
      var priceA = priceData.firstWhere((element) => element.idToken == poolPair.idTokenA, orElse: () => null);
      var priceB = priceData.firstWhere((element) => element.idToken == poolPair.idTokenB, orElse: () => null);

      var yearlyPoolReward = lpDailyDfiReward * poolPair.rewardPct * 365 * (dfiCoin != null ? dfiCoin.fiat : 0.0);

      var liquidityReserveidTokenA = poolPair.reserveA * (priceA != null ? priceA.fiat : 0.0);
      var liquidityReserveidTokenB = poolPair.reserveB * (priceB != null ? priceB.fiat : 0.0);
      var totalLiquidity = liquidityReserveidTokenA + liquidityReserveidTokenB;
      var apr = poolPair.apr ?? 0.0;

      return new PoolPairLiquidity(
          tokenA: tokenA.symbol, tokenB: tokenB.symbol, poolPair: poolPair, totalLiquidityInUSDT: totalLiquidity, yearlyPoolReward: yearlyPoolReward, apr: apr);
    });

    for (Future<PoolPairLiquidity> f in result) {
      waitResult.add(await f);
    }

    return waitResult;
  }
}
