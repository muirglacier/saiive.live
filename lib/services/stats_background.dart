import 'dart:async';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/model/stats.dart';
import 'package:saiive.live/network/stats.dart';
import 'package:saiive.live/service_locator.dart';

class StatsBackgroundService {
  Stats stats;

  void update() async {
    stats = await sl<IStatsService>().getStats(DeFiConstants.DefiAccountSymbol);
  }

  Stats get() {
    return stats;
  }
}
