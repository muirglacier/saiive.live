import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:saiive.live/network/model/key_account_wrapper.dart';
import 'package:saiive.live/network/request/addresses_request.dart';
import 'package:saiive.live/network/response/error_response.dart';
import 'package:http/http.dart' as http;

class EnclosureAccountService {
  final serverAddress;
  final String network;
  String baseUri = "/api/v1/";

  EnclosureAccountService(this.serverAddress, this.network);

  Future<dynamic> makeHttpPostRequest(String url, String coin, dynamic request) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;
    final body = json.encode(request.toJson());

    var response = await http.post(Uri.parse(finalUrl), headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, body: body);

    if (response.statusCode != 200) {
      return ErrorResponse(response: response, error: response.body);
    }
    return response;
  }

  Future<List<KeyAccountWrapper>> getAccounts(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    var response = await makeHttpPostRequest('/accounts', coin, request);

    if (response is Response) {
      List<KeyAccountWrapper> keyAccountWrappers = json.decode(response.body).map<KeyAccountWrapper>((data) => KeyAccountWrapper.fromJson(data)).toList();

      return keyAccountWrappers;
    }
    return List<KeyAccountWrapper>.empty();
  }
}
