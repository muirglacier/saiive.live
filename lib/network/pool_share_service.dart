import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/pool_share.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

abstract class IPoolShareService {
  Future<List<PoolShare>> getMyPoolShare(
      String coin, List<String> addresses);
  Future<List<PoolShare>> getPoolShares(String coin);
}

class PoolShareService extends NetworkService implements IPoolShareService {
  Future<List<PoolShare>> getMyPoolShare(
      String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this
        .httpService
        .makeHttpPostRequest('/listminepoolshares', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<PoolShare> poolShares = json
        .decode(response.body)
        .values
        .map<PoolShare>((data) => PoolShare.fromJson(data))
        .toList();

    return poolShares;
  }

  Future<List<PoolShare>> getPoolShares(String coin) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/listpoolshares/0/100000/true', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<PoolShare> poolShares =
        response.values.map<PoolShare>((data) => PoolShare.fromJson(data)).toList();

    return poolShares;
  }
}
