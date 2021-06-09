import 'package:saiive.live/network/model/token.dart';
import 'package:saiive.live/network/token_service.dart';

class TokenServiceMock implements ITokenService {
  @override
  Future<Token> getToken(String coin, String token) async {
    if (token == "DFI") {
      final token = new Token(id: 0);

      return token;
    } else if (token == "BTC") {
      final token = new Token(id: 1);

      return token;
    } else {
      final token = new Token(id: 1);

      return token;
    }
  }

  @override
  Future<List<Token>> getTokens(String coin) async {
    var list = List<Token>.empty(growable: true);

    return list;
  }
}
