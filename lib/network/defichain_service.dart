import 'dart:async';

import 'package:defichainwallet/network/model/coin.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class DefichainService extends NetworkService {
  Future<Map<String, dynamic>> getStatsYieldFarming(String coin) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/list-yield-farming', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return response;
  }
}
