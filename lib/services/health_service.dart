import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class IHealthService {
  Future checkHealth(BuildContext context);
}

class HealthService implements IHealthService {
  @override
  Future checkHealth(BuildContext context) async {
    final apiService = sl.get<ApiService>();
    final isAlive = await apiService.healthService.isAlive("DFI");

    if (!isAlive) {
      sl.get<AppCenterWrapper>().trackEvent("healthService", <String, String>{"state": "notAlive"});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).wallet_offline),
          action: SnackBarAction(
            label: S.of(context).wallet_uptime_stats,
            onPressed: () async {
              final url = env["STATS_URL"];

              if (await canLaunch(url)) {
                await launch(url);
              }
            },
          )));
    }
  }
}
