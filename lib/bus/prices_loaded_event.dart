import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/network/model/price.dart';
import 'package:saiive.live/network/model/stats.dart';

class PricesLoadedEvent implements Event {
  final List<Price> prices;

  PricesLoadedEvent({this.prices});
}
