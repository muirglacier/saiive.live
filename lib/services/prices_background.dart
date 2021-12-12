import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/coingecko_service.dart';
import 'package:saiive.live/network/model/coin.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/price.dart';
import 'package:saiive.live/network/prices.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class PricesBackgroundService {
  List<Price> _prices;
  List<Coin> _coins;
  Coin _tether;

  void update() async {
    _prices = await sl<IPricesService>().getPrices(DeFiConstants.DefiAccountSymbol);

    var currency = await sl<ISharedPrefsUtil>().getCurrency();
    _coins = await sl.get<ICoingeckoService>().getCoins(DeFiConstants.DefiAccountSymbol, Currency.getCurrencyShortage(currency));
    _tether = _coins.firstWhere((element) => element.coin == "tether");

    EventTaxiImpl.singleton().fire(new PricesLoadedEvent(prices: get(), tetherPrice: _tether, currency: currency));
  }

  Coin tetherPrice() {
    return _tether;
  }

  List<Coin> getCoinPrices() {
    return _coins;
  }

  List<Price> get() {
    return _prices;
  }
}
