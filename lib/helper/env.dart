import 'package:saiive.live/appstate_container.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvHelper {
  static EnvironmentType getEnvironment() {
    var currentEnvironment = EnvironmentType.Unknonw;

    switch (env["ENV"]) {
      case "dev":
        currentEnvironment = EnvironmentType.Development;
        break;
      case "staging":
        currentEnvironment = EnvironmentType.Staging;
        break;
      case "prod":
        currentEnvironment = EnvironmentType.Production;
        break;
    }

    return currentEnvironment;
  }

  static String getAzBlobKey() {
    return env["AZ_STORAGE_KEY"];
  }

  static String environmentToString(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.Development:
        return "DEV";
      case EnvironmentType.Staging:
        return "STAGING";
      case EnvironmentType.Production:
        return "PRODUCTION";
      default:
        return "unkown";
    }
  }
}
