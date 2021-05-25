import 'package:saiive.live/appstate_container.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvHelper {
  EnvironmentType getEnvironment() {
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
}
