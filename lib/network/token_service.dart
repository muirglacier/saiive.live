import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/token_loaded_event.dart';
import 'package:defichainwallet/bus/tokens_loaded_event.dart';
import 'package:defichainwallet/network/model/token.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class TokenService extends NetworkService
{
  Future<List<Token>> getTokens(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tokens');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Token> tokens = json
        .decode(response.body)
        .map<Token>((data) => Token.fromJson(data))
        .toList();

    this.fireEvent(new TokensLoadedEvent(tokens: tokens));

    return tokens;
  }

  Future<Token> getToken(String coin, String token) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tokens/$token');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Token tokenResponse = Token.fromJson(response);

    this.fireEvent(new TokenLoadedEvent(token: tokenResponse));

    return tokenResponse;
  }
}