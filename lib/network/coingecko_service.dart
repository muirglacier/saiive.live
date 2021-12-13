import 'dart:async';

import 'package:saiive.live/network/model/coin.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class ICoingeckoService {
  Future<List<Coin>> getCoins(String coin, String currency);
}

class CoingeckoService extends NetworkService implements ICoingeckoService {
  Future<List<Coin>> getCoins(String coin, String currency) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/coin-price/$currency', coin, cached: false);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Coin> coins = response.entries.map<Coin>((data) => Coin.fromJson(data.value)).toList();

    return coins;
  }
}
