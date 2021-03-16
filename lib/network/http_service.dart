import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/network/cache_response.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/model/error.dart';
import 'package:defichainwallet/network/base_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService extends IHttpService {
  String serverAddress;
  String network;
  String baseUri = "/api/v1/";
  Map<String, CachedResponse> cachedResults = new Map<String, CachedResponse>();

  HttpService();

  static Future<dynamic> _parseJson(String str) async {
    return json.decode(str);
  }

  Future init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final rawValue = sharedPreferences.get(SharedPrefsUtil.cur_net);

    final chainNet = ChainNet.values[rawValue ?? ChainNet.Testnet.index];
    this.network = ChainHelper.chainNetworkString(chainNet);
    if (env.containsKey("API_URL")) {
      this.serverAddress = env['API_URL'];
    }
  }

  Future<Map<String, dynamic>> makeHttpGetRequest(String url, String coin, {cached: false}) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;

    if (cached && cachedResults.containsKey(finalUrl)) {
      var cachedResult = cachedResults[finalUrl];

      if (cachedResult.created + cachedResult.lifetime > DateTime.now().millisecondsSinceEpoch) {
        cachedResults.remove(finalUrl);
      } else {
        return cachedResult.data;
      }
    }

    http.Response response = await http.get(
      Uri.parse(finalUrl),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode != 200) {
      var error = ErrorResponse(response: response, error: response.body);
      throw error;
    }
    final decoded = await compute(HttpService._parseJson, response.body);
    if (decoded.containsKey("error")) {
      throw Error.fromJson(decoded);
    }

    if (cached) {
      cachedResults[finalUrl] = new CachedResponse(60 * 60, DateTime.now().millisecondsSinceEpoch, decoded);
    }

    return decoded;
  }

  Future<dynamic> makeDynamicHttpGetRequest(String url, String coin, {cached: false}) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;

    if (cached && cachedResults.containsKey(finalUrl)) {
      var cachedResult = cachedResults[finalUrl];

      if (cachedResult.created + cachedResult.lifetime > DateTime.now().millisecondsSinceEpoch) {
        cachedResults.remove(finalUrl);
      } else {
        return cachedResult.data;
      }
    }

    http.Response response = await http.get(
      Uri.parse(finalUrl),
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return ErrorResponse(response: response, error: response.body);
    }

    if (cached) {
      cachedResults[finalUrl] = new CachedResponse(60 * 60, DateTime.now().millisecondsSinceEpoch, response);
    }

    return response;
  }

  Future<dynamic> makeHttpPostRequest(String url, String coin, BaseRequest request) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;
    final body = json.encode(request.toJson());

    http.Response response = await http.post(Uri.parse(finalUrl), headers: {'Content-type': 'application/json', 'Accept': 'application/json'}, body: body);
    if (response.statusCode != 200) {
      return ErrorResponse(response: response, error: response.body);
    }
    return response;
  }
}
