import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/network/model/stats.dart';

class StatsLoadedEvent implements Event {
  final Stats stats;

  StatsLoadedEvent({this.stats});
}
