import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/model/price.dart';
import 'package:saiive.live/network/prices.dart';
import 'package:saiive.live/service_locator.dart';

class PricesBackgroundService {
  List<Price> prices;

  void update() async {
    prices = await sl<IPricesService>().getPrices(DeFiConstants.DefiAccountSymbol);
  }

  List<Price> get() {
    return prices;
  }
}
