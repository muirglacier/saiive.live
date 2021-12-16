import 'dart:async';
import 'dart:convert';

import 'package:saiive.live/bus/accounts_loaded_event.dart';
import 'package:saiive.live/bus/key_account_wrappers_loaded_event.dart';
import 'package:saiive.live/network/base_service.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/key_account_wrapper.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/request/addresses_request.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IAccountService extends IBaseService {
  Future<List<Account>> getAccount(String coin, String address);
  Future<List<KeyAccountWrapper>> getAccounts(String coin, List<String> addresses);
}

class AccountService extends NetworkService implements IAccountService {
  Future<List<Account>> getAccount(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/account/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Account> accounts = json.decode(response.body).map<Account>((data) => Account.fromJson(data)).toList();

    this.fireEvent(new AccountsLoadedEvent(accounts: accounts));

    return accounts;
  }

  Future<List<KeyAccountWrapper>> getAccounts(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/accounts', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<KeyAccountWrapper> keyAccountWrappers = json.decode(response.body).map<KeyAccountWrapper>((data) => KeyAccountWrapper.fromJson(data)).toList();

    this.fireEvent(new KeyAccountWrappersLoadedEvent(keyAccountWrappers: keyAccountWrappers));

    return keyAccountWrappers;
  }
}
