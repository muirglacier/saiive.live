import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:event_taxi/event_taxi.dart';

class PoolPairsLoadedEvent implements Event {
  final List<PoolPair> poolPairs;

  PoolPairsLoadedEvent({this.poolPairs});
}