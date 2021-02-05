import 'dart:async';

import 'package:defichainwallet/network/model/coin.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class GovService extends NetworkService {
  Future<Map<String, dynamic>> getGov(String coin) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/gov', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return response;
  }
}
