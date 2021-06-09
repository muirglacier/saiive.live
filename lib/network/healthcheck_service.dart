import 'dart:async';

import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/network_service.dart';

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
