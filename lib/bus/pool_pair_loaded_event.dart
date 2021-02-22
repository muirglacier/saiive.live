import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:event_taxi/event_taxi.dart';

class PoolPairLoadedEvent implements Event {
  final PoolPair poolPair;

  PoolPairLoadedEvent({this.poolPair});
}
