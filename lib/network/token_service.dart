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
  Map<String, Map<String, Token>> _tokenMap = Map<String, Map<String, Token>>();

  Future<List<Token>> getTokens(String coin) async {
    if (_tokenMap.isNotEmpty && _tokenMap[this.httpService.getNetwork()].isNotEmpty) {
      return _tokenMap[this.httpService.getNetwork()].values.toList();
    }

    dynamic map = await this.httpService.makeHttpGetRequest('/tokens', coin);

    if (map is ErrorResponse) {
      this.handleError(map);
    }

    List<Token> tokens = map.entries.map<Token>((data) => Token.fromJson(data.value)).toList();

    this.fireEvent(new TokensLoadedEvent(tokens: tokens));
    if (!_tokenMap.containsKey(this.httpService.getNetwork())) {
      _tokenMap.putIfAbsent(this.httpService.getNetwork(), () => new Map<String, Token>());
    }

    for (final token in tokens) {
      _tokenMap[this.httpService.getNetwork()].putIfAbsent(token.symbolKey, () => token);
    }

    return tokens;
  }

  Future<Token> getToken(String coin, String token) async {
    if (_tokenMap.isNotEmpty && _tokenMap.containsKey(this.httpService.getNetwork()) && _tokenMap[this.httpService.getNetwork()].containsKey(token)) {
      return _tokenMap[this.httpService.getNetwork()][token];
    } else {
      _tokenMap[this.httpService.getNetwork()].clear();
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
