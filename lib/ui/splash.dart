import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info/package_info.dart';
import '../appstate_container.dart';
import '../generated/l10n.dart';

import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/widgets/auto_resize_text.dart';
import 'package:defichainwallet/ui/styles.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/model/vault.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  var _version = "";
  bool _hasCheckedLoggedIn;
  bool _retried;

  Future checkLoggedIn() async {
    if (!_hasCheckedLoggedIn) {
      _hasCheckedLoggedIn = true;
    } else {
      return;
    }
    
    try {
      // iOS key store is persistent, so if this is first launch then we will clear the keystore
      bool firstLaunch = await sl.get<SharedPrefsUtil>().getFirstLaunch();
      if (firstLaunch) {
        await sl.get<Vault>().deleteAll();
      }
      await sl.get<SharedPrefsUtil>().setFirstLaunch();
      // See if logged in already
      bool isLoggedIn = false;
      var seed = await sl.get<Vault>().getSeed();

      // If we have a seed set, but not a pin - or vice versa
      // Then delete the seed and pin from device and start over.
      // This would mean user did not complete the intro screen completely.
      if (seed != null) {
        isLoggedIn = true;
      }

      var route = '/intro_welcome';
      if (isLoggedIn) {
        route = '/home';
      }

      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      await sl.get<Vault>().deleteAll();
      await sl.get<SharedPrefsUtil>().deleteAll();
      if (!_retried) {
        _retried = true;
        _hasCheckedLoggedIn = false;
        checkLoggedIn();
      }
    }
  }

  void _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    setState(() {
      _version = version + "." + buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();

    WidgetsBinding.instance.addObserver(this);
    _hasCheckedLoggedIn = false;
    _retried = false;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => checkLoggedIn());

    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Account for user changing locale when leaving the app
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).title,
            style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w800),
          ),
          Image.asset('assets/logo.png'),
          SizedBox(height: 20),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: AutoSizeText(
                    _version,
                    style: AppStyles.textStyleParagraph(context),
                    maxLines: 4,
                    stepGranularity: 0.5,
                  ),
                ),
              ])
        ],
      )),
    );
  }
}
