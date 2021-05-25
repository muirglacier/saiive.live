import 'dart:async';

import 'package:saiive.live/bus/fee_estimate_loaded_event.dart';
import 'package:saiive.live/network/model/feeEstimate.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

class FeeService extends NetworkService {
  Future<FeeEstimate> getFee(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/accounts', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    FeeEstimate feeEstimate = FeeEstimate.fromJson(response);

    this.fireEvent(new FeeEstimateLoadedEvent(feeEstimate: feeEstimate));

    return feeEstimate;
  }
}
