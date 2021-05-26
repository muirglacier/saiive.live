import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/helper/env.dart';

abstract class IEnvironmentService {
  Future<EnvironmentType> getCurrentEnvironment();
}

class EnvironmentService implements IEnvironmentService {
  @override
  Future<EnvironmentType> getCurrentEnvironment() {
    var currentEnvironment = EnvHelper.getEnvironment();

    return Future.value(currentEnvironment);
  }
}
