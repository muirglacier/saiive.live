import 'dart:convert';

import 'package:saiive.live/network/base_request.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:http/http.dart' as http;

class MockHttpService extends IHttpService {
  String baseUri = "/api/v1/";

  @override
  Future init() {
    return Future.delayed(Duration(microseconds: 1));
  }

  @override
  Future<Map<String, dynamic>> makeHttpGetRequest(String url, String coin, {cached: false}) async {
    final finalUrl = "https://dev-supernode.defichain-wallet.com" + baseUri + "testnet" + "/" + coin + url;
    var response = await http.get(
      Uri.parse(finalUrl),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return null;
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      throw Error();
    }
    return decoded;
  }

  @override
  Future<Map<String, dynamic>> makeDynamicHttpGetRequest(String url, String coin, {cached: false}) async {
    await Future.delayed(Duration(microseconds: 1));
    return null;
  }

  @override
  Future makeHttpPostRequest(String url, String coin, BaseRequest request) async {
    await Future.delayed(Duration(microseconds: 1));
    return null;
  }

  @override
  String getNetwork() {
    return "testnet";
  }

  @override
  String getServerAddress() => "mock";
}
