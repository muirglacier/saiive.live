import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/accounts_loaded_event.dart';
import 'package:defichainwallet/bus/key_account_wrappers_loaded_event.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/key_account_wrapper.dart';
import 'package:defichainwallet/network/model/pool_share.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class PoolShareService extends NetworkService {
  Future<List<PoolShare>> getMyPoolShare(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this
        .httpService
        .makeHttpPostRequest('/listminepoolshares', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<PoolShare> poolShares = json
        .decode(response.body).values
        .map<PoolShare>((data) => PoolShare.fromJson(data))
        .toList();

    return poolShares;
  }
}
