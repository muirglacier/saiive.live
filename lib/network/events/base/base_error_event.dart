import 'package:event_taxi/event_taxi.dart';

class BaseErrorEvent extends Event {
  final bool hasError;
  final Error error;

  BaseErrorEvent({this.hasError = false, this.error});
}
