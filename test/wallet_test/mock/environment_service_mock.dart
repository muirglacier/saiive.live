import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/services/env_service.dart';

class EnvironmentServiceMock implements IEnvironmentService {
  @override
  Future<EnvironmentType> getCurrentEnvironment() {
    return Future.value(EnvironmentType.Development);
  }
}
