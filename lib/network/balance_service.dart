import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/balance.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';


Map decodeJson(dynamic src) {
  return json.decode(src);
}

class BalanceService extends NetworkService
{
  Future<List<Balance>> getAllBalances(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/balance-all/$address');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();
  }

  Future<List<Balance>> getAllBalancesAddresses(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/balance-all', request: request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();
  }

  Future<Balance> getBalance(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/balance/$address');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return Balance.fromJson(response);
  }

  Future<Balance> getBalancesAddresses(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/$coin/balances', request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();
  }

}