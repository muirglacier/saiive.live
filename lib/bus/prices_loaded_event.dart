import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/network/model/coin.dart';
import 'package:saiive.live/network/model/currency.dart';
import 'package:saiive.live/network/model/price.dart';

class PricesLoadedEvent implements Event {
  final List<Price> prices;
  final Coin tetherPrice;
  final CurrencyEnum currency;

  PricesLoadedEvent({this.prices, this.tetherPrice, this.currency});
}

class PriceLoadingStarted implements Event {}

class PricesStartLoadEvent implements Event {}
