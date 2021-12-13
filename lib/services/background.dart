import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/bus/prices_loaded_event.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/services/prices_background.dart';

class BackgroundService {
  Timer _statsTimer;
  Timer _priceTimer;

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

  Future startPriceTimer() async {
    sl<PricesBackgroundService>().update();

    EventTaxiImpl.singleton().registerTo<PricesStartLoadEvent>().listen((a) {
      sl<PricesBackgroundService>().update();
    });

    _statsTimer = Timer.periodic(Duration(minutes: 10), (tick) {
      sl<PricesBackgroundService>().update();
    });
  }
}
