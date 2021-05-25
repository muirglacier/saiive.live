import 'package:saiive.live/appstate_container.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WalletLogFilter extends LogFilter {
  EnvironmentType _currentEnvironment = EnvironmentType.Unknonw;

  void _initGetFlavor() async {
    var currentEnvironment = EnvironmentType.Unknonw;
    var packageInfo = await PackageInfo.fromPlatform();
    switch (packageInfo.packageName) {
      case "at.saiive.live.dev":
        currentEnvironment = EnvironmentType.Development;
        break;
      case "at.saiive.live.staging":
        currentEnvironment = EnvironmentType.Staging;
        break;
      case "at.saiive.live":
        currentEnvironment = EnvironmentType.Production;
        break;
    }
    _currentEnvironment = currentEnvironment;
  }

  @override
  void init() {
    _initGetFlavor();
    super.init();
  }

  @override
  bool shouldLog(LogEvent event) {
    if (_currentEnvironment == EnvironmentType.Production) {
      return false;
    }
    return true;
  }
}
