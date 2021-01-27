import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/token.dart';
import 'package:event_taxi/event_taxi.dart';

class TokensLoadedEvent implements Event {
  final List<Token> tokens;

  TokensLoadedEvent({this.tokens});
}