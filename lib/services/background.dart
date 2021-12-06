import 'dart:async';

import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';

class BackgroundService {
  Timer _statsTimer = null;

  void start() {
    startBackgroundStatsTimer();
  }

  void stop() {
    if (_statsTimer.isActive) {
      _statsTimer.cancel();
      _statsTimer = null;
    }
  }

  void startBackgroundStatsTimer() {
    sl<StatsBackgroundService>().update();

    _statsTimer = Timer.periodic(Duration(seconds: 30), (tick) {
      sl<StatsBackgroundService>().update();
    });
  }
}
