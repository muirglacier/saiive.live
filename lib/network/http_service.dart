import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/error.dart';
import 'package:defichainwallet/network/base_request.dart';

import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

class HttpService {
  String serverAddress;

  HttpService() {
    this.serverAddress = FlutterConfig.get('API_URL');
  }

  Future<Map<String, String>> makeHttpGetRequest(String url) async {
    http.Response response = await http.get(
      this.serverAddress + url,
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

  Future<dynamic> makeHttpPostRequest(String url, BaseRequest request) async {
    final body = json.encode(request.toJson());
    http.Response response = await http.post(this.serverAddress + url,
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
