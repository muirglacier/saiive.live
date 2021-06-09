import 'package:saiive.live/network/model/key_account_wrapper.dart';
import 'package:event_taxi/event_taxi.dart';

class KeyAccountWrappersLoadedEvent implements Event {
  final List<KeyAccountWrapper> keyAccountWrappers;

  KeyAccountWrappersLoadedEvent({this.keyAccountWrappers});
}
