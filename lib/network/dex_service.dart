import 'dart:async';
import 'dart:convert';

import 'package:saiive.live/bus/pool_pair_loaded_event.dart';
import 'package:saiive.live/network/model/pool_pair.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IDexService {
  Future<PoolPair> getPoolPair(String coin, String poolID);
}

class DexService extends NetworkService implements IDexService {
  Future<PoolPair> getPoolPair(String coin, String poolID) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/getpoolpairs/$poolID', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    PoolPair poolPair = PoolPair.fromJson(response);

    this.fireEvent(new PoolPairLoadedEvent(poolPair: poolPair));

    return poolPair;
  }
}
