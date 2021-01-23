import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:device_info/device_info.dart';

class AppCenterWrapper {
  Future start() async {
    await AppCenter.startAsync(
      appSecretAndroid: '89cdcc88-5073-4b4a-9235-29e12c47d731',
      appSecretIOS: '374b0829-a9ee-401c-8187-ab0f0ebbec83',
      enableAnalytics: true,
      enableCrashes: true,
      enableDistribute: true,
      usePrivateDistributeTrack: false,
      disableAutomaticCheckForUpdate: false,
    );

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        var deviceInfo = await deviceInfoPlugin.androidInfo;

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
      AppCenter.trackEventAsync('startAppDeviceInfoError', <String, String>{
        'os': Platform.isAndroid ? "android" : "ios",
        'error': e.message
      });
    }
  }

  Future trackEvent(String eventName, Map<String, String> properties) async {
    try {
      await AppCenter.trackEventAsync(eventName, properties);
    } on Exception catch (e) {
      debugPrint("error track event: " + e.toString());
    }
  }
}
