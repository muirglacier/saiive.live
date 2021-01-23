import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/model/account.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class AccountService extends NetworkService
{
  Future<List<Account>> getAccount(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/account/$address');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Account>((data) => Account.fromJson(data))
        .toList();
  }

  Future<List<Account>> getAccounts(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/$coin/accounts', request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Account>((data) => Account.fromJson(data))
        .toList();
  }
}