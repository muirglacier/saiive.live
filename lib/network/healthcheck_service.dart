import 'dart:async';

import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:defichainwallet/network/network_service.dart';

abstract class IHealthCheckService {
  Future<bool> isAlive(String coin);
}

class HealthCheckService extends NetworkService implements IHealthCheckService {
  @override
  Future<bool> isAlive(String coin) async {
    try {
      await this.httpService.makeHttpGetRequest("/health", coin);
      return true;
    } catch (e) {
      LogHelper.instance.e(e);
    }
    return false;
  }
}
