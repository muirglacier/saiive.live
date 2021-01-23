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

  Future<dynamic> makeHttpGetRequest(String url, {BaseRequest request = null}) async {
    http.Response response = await http.post(this.serverAddress + url,
        headers: {'Content-type': 'application/json'},
        body: request != null ? json.encode(request.toJson()) : null
    );

    if (response.statusCode != 200) {
      return null;
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      return Error.fromJson(decoded);
    }
    return decoded;
  }

  Future<dynamic> makeHttpPostRequest(String url, BaseRequest request) async {
    http.Response response = await http.post(this.serverAddress + url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      return null;
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      return Error.fromJson(decoded);
    }
    return decoded;
  }
}
