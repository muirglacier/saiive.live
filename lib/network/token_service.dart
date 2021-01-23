import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/model/token.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class TokenService extends NetworkService
{
  Future<List<Token>> getTokens(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tokens');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Token>((data) => Token.fromJson(data))
        .toList();
  }

  Future<Token> getToken(String coin, String token) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tokens/$token');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return Token.fromJson(response);
  }
}