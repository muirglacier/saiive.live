import 'dart:async';

import 'package:saiive.live/bus/stats_loaded_event.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class IStatsService {
  Future<Stats> getStats(String coin);
}

class StatsService extends NetworkService implements IStatsService {
  Future<Stats> getStats(String coin) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/stats', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Stats stats = Stats.fromJson(response);

    this.fireEvent(new StatsLoadedEvent(stats: stats));

    return stats;
  }
}
