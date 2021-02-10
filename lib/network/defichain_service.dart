import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/yield_farming.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

abstract class IDefichainService {
  Future<List<YieldFarming>> getStatsYieldFarming(String coin);
}

class DefichainService extends NetworkService implements IDefichainService {
  Future<List<YieldFarming>> getStatsYieldFarming(String coin) async {
    dynamic response =
        await this.httpService.makeDynamicHttpGetRequest('/list-yield-farming', coin, cached: true);

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
