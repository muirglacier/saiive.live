import 'package:defichainwallet/network/model/balance.dart';
import 'package:defichainwallet/network/model/block.dart';
import 'package:event_taxi/event_taxi.dart';

class BlockLoadedEvent implements Event {
  final Block block;

  BlockLoadedEvent({this.block});
}
