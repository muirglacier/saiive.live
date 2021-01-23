import 'dart:async';

import 'package:defichainwallet/network/model/feeEstimate.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class FeeService extends NetworkService
{
  Future<FeeEstimate> getFee(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/accounts');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return FeeEstimate.fromJson(response);
  }
}