import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class VersionHelper {
  Future<String> getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return version;
    }

    return version + "." + buildNumber;
  }
}
