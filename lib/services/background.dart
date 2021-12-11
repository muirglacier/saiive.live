import 'dart:async';

import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/services/prices_background.dart';

class BackgroundService {
  Timer _statsTimer = null;
  Timer _priceTimer = null;

  void start() {
    startBackgroundStatsTimer();
    startPriceTimer();
  }

  void stop() {
    if (_statsTimer.isActive) {
      _statsTimer.cancel();
      _statsTimer = null;
    }
    if (_priceTimer.isActive) {
      _priceTimer.cancel();
      _priceTimer = null;
    }
  }

  void startBackgroundStatsTimer() {
    sl<StatsBackgroundService>().update();

    _statsTimer = Timer.periodic(Duration(seconds: 30), (tick) {
      sl<StatsBackgroundService>().update();
    });
  }

  void startPriceTimer() {
    sl<PricesBackgroundService>().update();

    _statsTimer = Timer.periodic(Duration(minutes: 10), (tick) {
      sl<PricesBackgroundService>().update();
    });
  }
}
