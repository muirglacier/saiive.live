import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class IHealthService {
  Future checkHealth(BuildContext context);
}

class HealthService implements IHealthService {
  @override
  Future checkHealth(BuildContext context) async {
    final walletService = sl.get<IWalletService>();

    final aliveService = await walletService.getIsAlive();

    var allAlive = true;
    var deadChains = StringBuffer();

    for (var alive in aliveService.entries) {
      sl.get<AppCenterWrapper>().trackEvent("healthService", <String, String>{"state": "notAlive", "chain": alive.key});

      if (!alive.value) {
        allAlive = false;
        deadChains.write(alive.key);
        deadChains.write(",");
      }
    }

    if (!allAlive) {
      var deadChainsString = deadChains.toString();
      deadChainsString = deadChainsString.substring(0, deadChainsString.length - 1);

      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).wallet_offline(deadChainsString)),
            // duration: Duration(days: 1),
            action: SnackBarAction(
              label: S.of(context).wallet_uptime_stats,
              onPressed: () async {
                final url = env["STATS_URL"];

                await launch(url);
              },
            )));
      } catch (e) {}
    }
  }
}
