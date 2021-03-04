import 'dart:async';
import 'dart:io';
import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/helper/env.dart';
import 'package:defichainwallet/helper/version.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../generated/l10n.dart';

import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/widgets/auto_resize_text.dart';
import 'package:defichainwallet/ui/styles.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  var _version = "";
  bool _hasCheckedLoggedIn;
  bool _retried;

  EnvironmentType _currentEnvironment;

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
        await sl.get<IVault>().deleteAll();
      }
      await sl.get<SharedPrefsUtil>().setFirstLaunch();
      // See if have already a seed generated
      bool hasSeedGenerated = true;
      var seed = await sl.get<IVault>().getSeed();

      hasSeedGenerated = seed != null;

      var route = '/intro_welcome';
      if (hasSeedGenerated) {
        route = '/home';
      }
      await sl.allReady();

      if (hasSeedGenerated) {
        final wallet = sl.get<DeFiChainWallet>();
        await wallet.init();
      }
      // await sl.get<IWalletDatabase>().open();

      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      await sl.get<IVault>().deleteAll();
      await sl.get<SharedPrefsUtil>().deleteAll();
      if (!_retried) {
        _retried = true;
        _hasCheckedLoggedIn = false;
        checkLoggedIn();
      }
    }
  }

  void _init() async {
    _currentEnvironment = EnvHelper().getEnvironment();
    _version = await VersionHelper().getVersion();
  }

  @override
  void initState() {
    super.initState();

    _init();

    WidgetsBinding.instance.addObserver(this);
    _hasCheckedLoggedIn = false;
    _retried = false;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
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
    var height = MediaQuery.of(context).size.height;

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      height = height / 2;
    }
    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).title,
            style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800),
          ),
          Container(child: Image.asset('assets/logo.png', height: height)),
          SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: AutoSizeText(
                _version,
                style: AppStyles.textStyleParagraph(context),
                maxLines: 4,
                stepGranularity: 0.5,
              ),
            ),
          ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))]),
          if (_currentEnvironment != EnvironmentType.Production)
            Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: AutoSizeText(
                  _currentEnvironment.toString(),
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
