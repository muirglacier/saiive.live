import 'dart:async';

import 'package:defichainwallet/network/model/coin.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

abstract class ICoingeckoService {
  Future<List<Coin>> getCoins(String coin, String currency);
}

class CoingeckoService extends NetworkService implements ICoingeckoService {
  Future<List<Coin>> getCoins(String coin, String currency) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/coin-price/$currency', coin, cached: true);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Coin> coins = response.entries
        .map<Coin>((data) => Coin.fromJson(data.value))
        .toList();

    return coins;
  }
}
