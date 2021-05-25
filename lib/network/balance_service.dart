import 'dart:async';
import 'dart:convert';

import 'package:saiive.live/bus/balance_loaded_event.dart';
import 'package:saiive.live/bus/balances_loaded_event.dart';
import 'package:saiive.live/network/model/balance.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/request/addresses_request.dart';
import 'package:saiive.live/network/response/error_response.dart';
import 'package:flutter/foundation.dart';

Map decodeJson(dynamic src) {
  return json.decode(src);
}

abstract class IBalanceService {
  Future<List<Balance>> getAllBalances(String coin, String address);
  Future<List<Balance>> getAllBalancesAddresses(String coin, List<String> addresses);
  Future<Balance> getBalance(String coin, String address);
  Future<List<Balance>> getBalancesAddresses(String coin, List<String> addresses);
}

class BalanceService extends NetworkService implements IBalanceService {
  Future<List<Balance>> getAllBalances(String coin, String address) async {
    dynamic response = await this.httpService.makeDynamicHttpGetRequest('/balance-all/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final balances = await compute(balancesFromJson, response);
    this.fireEvent(new BalancesLoadedEvent(balances: balances));

    return balances;
  }

  Future<List<Balance>> getAllBalancesAddresses(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/balance-all', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final balances = await compute(balancesFromJson, response);

    this.fireEvent(new BalancesLoadedEvent(balances: balances));

    return balances;
  }

  Future<Balance> getBalance(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/balance/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Balance balance = Balance.fromJson(response);

    this.fireEvent(new BalanceLoadedEvent(balance: balance));

    return balance;
  }

  Future<List<Balance>> getBalancesAddresses(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/balances', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final balances = await compute(balancesFromJson, response);

    this.fireEvent(new BalancesLoadedEvent(balances: balances));

    return balances;
  }
}
