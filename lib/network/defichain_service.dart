import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/yield_farming.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class DefichainService extends NetworkService {
  Future<List<YieldFarming>> getStatsYieldFarming(String coin) async {
    dynamic response =
        await this.httpService.makeDynamicHttpGetRequest('/list-yield-farming', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<YieldFarming> yieldFarmingList = json
        .decode(response.body)
        .map<YieldFarming>((data) => YieldFarming.fromJson(data))
        .toList();

    return yieldFarmingList;
  }
}
