import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';

class AppCenterWrapper {
  AndroidDeviceInfo _android;
  IosDeviceInfo _ios;

  Future start() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      //TODO: DESKTOP
      return;
    }

    final android = env["APPCENTER_ANDROID_ID"];
    final iOs = env["APPCENTER_IOS_ID"];
    await AppCenter.startAsync(
        appSecretAndroid: android,
        appSecretIOS: iOs,
        enableAnalytics: true,
        enableCrashes: true,
        enableDistribute: true,
        usePrivateDistributeTrack: false,
        disableAutomaticCheckForUpdate: true);

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        var deviceInfo = await deviceInfoPlugin.androidInfo;
        _android = deviceInfo;

        this.trackEvent('startApp', <String, String>{
          'os': "android",
          'brand': deviceInfo.brand,
          'device': deviceInfo.device,
          'hardware': deviceInfo.hardware,
          'manufacturer': deviceInfo.manufacturer,
          'model': deviceInfo.model,
          'id': deviceInfo.androidId,
          'baseOs': deviceInfo.version.baseOS,
          'release': deviceInfo.version.release,
          'sdkInt': deviceInfo.version.sdkInt.toString(),
          'codename': deviceInfo.version.codename,
          'isPhysicalDevice': deviceInfo.isPhysicalDevice.toString()
        });
      } else if (Platform.isIOS) {
        var deviceInfo = await deviceInfoPlugin.iosInfo;
        _ios = deviceInfo;
        this.trackEvent('startApp', <String, String>{
          'os': "ios",
          'name': deviceInfo.name,
          'systemName': deviceInfo.systemName,
          'systemVersion': deviceInfo.systemVersion,
          'model': deviceInfo.model,
          'id': deviceInfo.identifierForVendor,
          'sysname': deviceInfo.utsname.sysname,
          'nodename': deviceInfo.utsname.nodename,
          'release': deviceInfo.utsname.release,
          'version': deviceInfo.utsname.version,
          'machine': deviceInfo.utsname.machine,
          'isPhysicalDevice': deviceInfo.isPhysicalDevice.toString()
        });
      }
    } on PlatformException catch (e) {
      AppCenter.trackEventAsync('startAppDeviceInfoError', <String, String>{'os': Platform.isAndroid ? "android" : "ios", 'error': e.message});
    }
  }

  Future trackEvent(String eventName, Map<String, String> properties) async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      //TODO: DESKTOP
      return;
    }

    try {
      assert(properties != null);

      if (Platform.isAndroid && _android != null) {
        properties.putIfAbsent("os", () => "android");
        properties.putIfAbsent("brand", () => _android.brand);
        properties.putIfAbsent("device", () => _android.device);
        properties.putIfAbsent("hardware", () => _android.hardware);
        properties.putIfAbsent("manufacturer", () => _android.manufacturer);
        properties.putIfAbsent("model", () => _android.model);
        properties.putIfAbsent("id", () => _android.id);
        properties.putIfAbsent("baseOs", () => _android.version.baseOS);
        properties.putIfAbsent("release", () => _android.version.release);
        properties.putIfAbsent("sdkInt", () => _android.version.sdkInt.toString());
        properties.putIfAbsent("codename", () => _android.version.codename);
        properties.putIfAbsent("isPhysicalDevice", () => _android.isPhysicalDevice.toString());
      } else if (Platform.isIOS && _ios != null) {
        properties.putIfAbsent("os", () => "android");
        properties.putIfAbsent("name", () => _ios.name);
        properties.putIfAbsent("systemName", () => _ios.systemName);
        properties.putIfAbsent("systemVersion", () => _ios.systemVersion);
        properties.putIfAbsent("id", () => _ios.identifierForVendor);
        properties.putIfAbsent("sysname", () => _ios.systemName);
        properties.putIfAbsent("nodename", () => _ios.utsname.nodename);
        properties.putIfAbsent("release", () => _ios.utsname.version);
        properties.putIfAbsent("version", () => _ios.utsname.version);
        properties.putIfAbsent("machine", () => _ios.utsname.machine);
        properties.putIfAbsent("isPhysicalDevice", () => _ios.isPhysicalDevice.toString());
      }
      await AppCenter.trackEventAsync(eventName, properties);
    } on Exception catch (e) {
      LogHelper.instance.e("error track event", e);
    }
  }
}
