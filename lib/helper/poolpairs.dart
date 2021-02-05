import 'package:defichainwallet/network/coingecko_service.dart';
import 'package:defichainwallet/network/defichain_service.dart';
import 'package:defichainwallet/network/gov_service.dart';
import 'package:defichainwallet/network/model/pool_pair_liqudity.dart';
import 'package:defichainwallet/service_locator.dart';

class PoolPairsHelper {
  Future<List<PoolPairLiquidity>> getPoolPairs(String coin, String currency) async {
    var gov = await sl.get<GovService>().getGov(coin);
    var lpDailyDfiReward = gov['LP_DAILY_DFI_REWARD'];
    var poolStats = await sl.get<DefichainService>().getStatsYieldFarming(coin);
    var priceData = await sl.get<CoingeckoService>().getCoins(coin, currency);

    
  }
}
