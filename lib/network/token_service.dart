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
  Map<String, Token> _tokenMap = Map<String, Token>();

  Future<List<Token>> getTokens(String coin) async {
    if (_tokenMap.isNotEmpty) {
      return _tokenMap.values.toList();
    }

    dynamic map = await this.httpService.makeHttpGetRequest('/tokens', coin);

    if (map is ErrorResponse) {
      this.handleError(map);
    }

    List<Token> tokens = map.entries.map<Token>((data) => Token.fromJson(data.value)).toList();

    this.fireEvent(new TokensLoadedEvent(tokens: tokens));

    for (final token in tokens) {
      _tokenMap.putIfAbsent(token.symbolKey, () => token);
    }

    return tokens;
  }

  Future<Token> getToken(String coin, String token) async {
    if (_tokenMap.isNotEmpty && _tokenMap.containsKey(token)) {
      return _tokenMap[token];
    } else {
      _tokenMap.clear();
    }

    dynamic response = await this.httpService.makeHttpGetRequest('/tokens/$token', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Token tokenResponse = Token.fromJson(response);

    this.fireEvent(new TokenLoadedEvent(token: tokenResponse));

    return tokenResponse;
  }
}
