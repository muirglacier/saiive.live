import 'package:defichainwallet/network/model/balance.dart';
import 'package:event_taxi/event_taxi.dart';

class BalanceLoadedEvent implements Event {
  final Balance balance;

  BalanceLoadedEvent({this.balance});
}