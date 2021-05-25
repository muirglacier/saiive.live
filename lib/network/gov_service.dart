import 'dart:async';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IGovService {
  Future<Map<String, dynamic>> getGov(String coin);
}

class GovService extends NetworkService implements IGovService {
  Future<Map<String, dynamic>> getGov(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/gov', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return response;
  }
}
