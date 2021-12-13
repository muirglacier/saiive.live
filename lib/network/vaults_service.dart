import 'dart:async';
import 'dart:convert';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/request/addresses_request.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IVaultsService {
  Future<List<LoanVault>> getVaults(String coin);
  Future<List<LoanVault>> getMyVault(String coin, String address);
  Future<LoanVault> getVault(String coin, String address);
  Future<List<LoanVault>> getMyVaults(String coin, List<String> addresses);
}

class VaultsService extends NetworkService implements IVaultsService {
  Future<List<LoanVault>> getVaults(String coin) async {
    dynamic response =
        await this.httpService.makeDynamicHttpGetRequest('/loans/vaults', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanVault> vaults = json.decode(response.body).map<LoanVault>((data) => LoanVault.fromJson(data)).toList();

    return vaults;
  }

  Future<List<LoanVault>> getMyVault(String coin, String address) async {
    dynamic response = await this.httpService.makeDynamicHttpGetRequest('/address/loans/vaults/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanVault> vaults = json.decode(response.body).map<LoanVault>((data) => LoanVault.fromJson(data)).toList();

    return vaults;
  }

  Future<LoanVault> getVault(String coin, String address) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/loans/vaults/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    LoanVault vault = LoanVault.fromJson(response);

    return vault;
  }

  Future<List<LoanVault>> getMyVaults(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/address/loans/vaults', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanVault> vaults = json.decode(response.body).map<LoanVault>((data) => LoanVault.fromJson(data)).toList();

    return vaults;
  }
}
