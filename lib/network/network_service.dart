import 'dart:convert';
import 'package:defichainwallet/network/http_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';


Map decodeJson(dynamic src) {
  return json.decode(src);
}

abstract class NetworkService {
  HttpService httpService;

  NetworkService() {
    httpService = sl.get<HttpService>();
  }

  void handleError(ErrorResponse response) {
    throw Exception("Received error ${response.error}");
  }
}
