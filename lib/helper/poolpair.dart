import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/model/pool_pair_liquidity.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';

class PoolPairHelper {
  Future<List<PoolPairLiquidity>> getPoolPairs(String coin, String currency) async {
    var poolPairs = await sl.get<IPoolPairService>().getPoolPairs(coin);

    var tokens = await sl.get<ITokenService>().getTokens(DeFiConstants.DefiAccountSymbol);

    List<PoolPairLiquidity> waitResult = [];
    Iterable<Future<PoolPairLiquidity>> result = poolPairs.map((poolPair) async {
      var idTokenA = poolPair.idTokenA;
      var idTokenB = poolPair.idTokenB;

      var tokenA = tokens.singleWhere((element) => element.id.toString() == idTokenA);
      var tokenB = tokens.singleWhere((element) => element.id.toString() == idTokenB);

      return new PoolPairLiquidity(
          tokenA: tokenA.symbol,
          tokenB: tokenB.symbol,
          poolPair: poolPair,
          totalLiquidityInUSDT: poolPair.totalLiquidityUsd,
          apr: poolPair.apr ?? 0.0);
    });

    for (Future<PoolPairLiquidity> f in result) {
      waitResult.add(await f);
    }

    return waitResult;
  }
}
