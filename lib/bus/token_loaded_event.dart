import 'package:defichainwallet/network/model/token.dart';
import 'package:event_taxi/event_taxi.dart';

class TokenLoadedEvent implements Event {
  final Token token;

  TokenLoadedEvent({this.token});
}
