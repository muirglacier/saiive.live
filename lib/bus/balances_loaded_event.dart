import 'package:saiive.live/network/model/balance.dart';
import 'package:event_taxi/event_taxi.dart';

class BalancesLoadedEvent implements Event {
  final List<Balance> balances;

  BalancesLoadedEvent({this.balances});
}
