import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/model/error.dart';
import 'package:defichainwallet/network/base_request.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService extends IHttpService {
  String serverAddress;
  String network;
  String baseUri = "/api/v1/";

  HttpService();

  Future init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final rawValue = await sharedPreferences.get(SharedPrefsUtil.cur_net);

    final chainNet = ChainNet.values[rawValue ?? ChainNet.Testnet.index];
    this.network = ChainHelper.chainNetworkString(chainNet);
    if (env.containsKey("API_URL")) {
      this.serverAddress = env['API_URL'];
    }
  }

  Future<Map<String, dynamic>> makeHttpGetRequest(
      String url, String coin) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;
    http.Response response = await http.get(
      finalUrl,
      headers: {'Content-type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return null;
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      throw Error.fromJson(decoded);
    }
    return decoded;
  }

  Future<dynamic> makeHttpPostRequest(
      String url, String coin, BaseRequest request) async {
    final finalUrl = this.serverAddress + baseUri + network + "/" + coin + url;
    final body = json.encode(request.toJson());

    http.Response response = await http.post(finalUrl,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if (response.statusCode != 200) {
      return null;
    }
    return response;
  }
}
