import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/accounts_loaded_event.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:flutter/foundation.dart';

class KeyAccountWrapper {
  final String address;
  final List<Account> accounts;

  KeyAccountWrapper({@required this.address, @required this.accounts});

  factory KeyAccountWrapper.fromJson(Map<String, dynamic> json) {
    final accountList = (json['accounts'] as List);
    return KeyAccountWrapper(
        address: json['address'],
        accounts: accountList?.map((e) => Account.fromJson(e))?.toList());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'balance': accounts.map((e) => e.toJson()).toList()
      };
}

class AccountService extends NetworkService {
  Future<List<Account>> getAccount(String coin, String address) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/v1/api/$coin/account/$address');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Account> accounts = json
        .decode(response.body)
        .map<Account>((data) => Account.fromJson(data))
        .toList();

    this.fireEvent(new AccountsLoadedEvent(accounts: accounts));
    
    return accounts;
  }

  Future<List<KeyAccountWrapper>> getAccounts(
      String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this
        .httpService
        .makeHttpPostRequest('/v1/api/$coin/accounts', request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Account> accounts = json
        .decode(response.body)
        .map<KeyAccountWrapper>((data) => KeyAccountWrapper.fromJson(data))
        .toList();

    this.fireEvent(new AccountsLoadedEvent(accounts: accounts));

    return accounts;
  }
}
