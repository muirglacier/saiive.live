import 'package:saiive.live/network/model/block.dart';
import 'package:event_taxi/event_taxi.dart';

class BlockTipUpdatedEvent extends Event {
  final Block block;

  BlockTipUpdatedEvent({this.block});
}
