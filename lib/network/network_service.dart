import 'dart:convert';
import 'package:saiive.live/network/response/error_response.dart';
import 'package:saiive.live/service_locator.dart';

import 'package:event_taxi/event_taxi.dart';

import 'ihttp_service.dart';

Map decodeJson(dynamic src) {
  return json.decode(src);
}

class HttpException implements Exception {
  final ErrorResponse error;
  HttpException(this.error);
}

abstract class NetworkService {
  IHttpService httpService;

  NetworkService() {
    httpService = sl.get<IHttpService>();
  }

  String getServerAddress() {
    return httpService.getServerAddress();
  }

  String getNetwork() {
    return httpService.getNetwork();
  }

  void fireEvent(Event event) {
    EventTaxiImpl.singleton().fire(event);
  }

  void handleError(ErrorResponse response) {
    throw HttpException(response);
  }
}
