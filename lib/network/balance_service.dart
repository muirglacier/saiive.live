import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/balance_loaded_event.dart';
import 'package:defichainwallet/bus/balances_loaded_event.dart';
import 'package:defichainwallet/network/model/balance.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';


Map decodeJson(dynamic src) {
  return json.decode(src);
}

abstract class IBalanceService {
  Future<List<Balance>> getAllBalances(String coin, String address);
  Future<List<Balance>> getAllBalancesAddresses(String coin, List<String> addresses);
  Future<Balance> getBalance(String coin, String address);
  Future<List<Balance>> getBalancesAddresses(String coin, List<String> addresses);
}

class BalanceService extends NetworkService implements IBalanceService
{
  Future<List<Balance>> getAllBalances(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/balance-all/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Balance> balances = json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();
    
    this.fireEvent(new BalancesLoadedEvent(balances: balances));
    
    return balances;
  }

  Future<List<Balance>> getAllBalancesAddresses(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/balance-all', coin,  request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Balance> balances = json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();

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

    List<Balance> balances = json
        .decode(response.body)
        .map<Balance>((data) => Balance.fromJson(data))
        .toList();

    this.fireEvent(new BalancesLoadedEvent(balances: balances));

    return balances;
  }
}