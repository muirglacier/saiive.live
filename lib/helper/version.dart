import 'dart:io';

import 'package:package_info/package_info.dart';

class VersionHelper {
  Future<String> getVersion() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      //TODO: DESKTOP
      return "0.1";
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    return version + "." + buildNumber;
  }
}
