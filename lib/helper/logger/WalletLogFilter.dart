import 'package:defichainwallet/appstate_container.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';

class WalletLogFilter extends LogFilter {
  EnvironmentType _currentEnvironment = EnvironmentType.Unknonw;

  void _initGetFlavor() async {
    var currentEnvironment = EnvironmentType.Unknonw;
    var packageInfo = await PackageInfo.fromPlatform();
    switch (packageInfo.packageName) {
      case "com.defichain.wallet.dev":
        currentEnvironment = EnvironmentType.Development;
        break;
      case "com.defichain.wallet.staging":
        currentEnvironment = EnvironmentType.Staging;
        break;
      case "com.defichain.wallet":
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
