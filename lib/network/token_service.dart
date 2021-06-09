import 'dart:async';
import 'package:saiive.live/bus/token_loaded_event.dart';
import 'package:saiive.live/bus/tokens_loaded_event.dart';
import 'package:saiive.live/network/model/token.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class ITokenService {
  Future<List<Token>> getTokens(String coin);
  Future<Token> getToken(String coin, String token);
}

class TokenService extends NetworkService implements ITokenService {
  Future<List<Token>> getTokens(String coin) async {
    dynamic map = await this.httpService.makeHttpGetRequest('/tokens', coin);

    if (map is ErrorResponse) {
      this.handleError(map);
    }

    List<Token> tokens = map.entries.map<Token>((data) => Token.fromJson(data.value)).toList();

    this.fireEvent(new TokensLoadedEvent(tokens: tokens));

    return tokens;
  }

  Future<Token> getToken(String coin, String token) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/tokens/$token', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Token tokenResponse = Token.fromJson(response);

    this.fireEvent(new TokenLoadedEvent(token: tokenResponse));

    return tokenResponse;
  }
}
