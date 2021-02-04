import 'dart:convert';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';

import 'package:event_taxi/event_taxi.dart';

import 'ihttp_service.dart';

Map decodeJson(dynamic src) {
  return json.decode(src);
}

abstract class NetworkService {
  IHttpService httpService;

  NetworkService() {
    httpService = sl.get<IHttpService>();
  }

  void fireEvent(Event event) {
    EventTaxiImpl.singleton().fire(event);
  }

  void handleError(ErrorResponse response) {
    throw Exception("Received error ${response.error}");
  }
}
