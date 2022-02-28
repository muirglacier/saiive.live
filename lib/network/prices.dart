import 'dart:async';
import 'dart:convert';

import 'package:saiive.live/network/model/price.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IPricesService {
  Future<List<Price>> getPrices(String coin);
}

class PricesService extends NetworkService implements IPricesService {
  Future<List<Price>> getPrices(String coin) async {
    dynamic response = await this.httpService.makeDynamicHttpGetRequest('/prices', coin, cached: true);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Price> prices = json.decode(response.body).map<Price>((data) => Price.fromJson(data)).toList();

    return prices;
  }
}
