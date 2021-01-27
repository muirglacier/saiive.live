import 'package:defichainwallet/network/model/balance.dart';
import 'package:defichainwallet/network/model/block.dart';
import 'package:defichainwallet/network/model/feeEstimate.dart';
import 'package:event_taxi/event_taxi.dart';

class FeeEstimateLoadedEvent implements Event {
  final FeeEstimate feeEstimate;

  FeeEstimateLoadedEvent({this.feeEstimate});
}
