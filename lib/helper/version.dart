import 'package:package_info/package_info.dart';

class VersionHelper {
  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    return version + "." + buildNumber;
  }
}
