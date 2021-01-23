import 'dart:async';
import 'dart:io';

import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/model/available_language.dart';
import 'package:defichainwallet/ui/splash.dart';
import 'package:defichainwallet/ui/home.dart';
import 'package:defichainwallet/ui/intro/intro_welcome.dart';
import 'package:defichainwallet/ui/intro/intro_restore.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_config/flutter_config.dart';

import 'helper/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  await FlutterConfig.loadEnvVariables();

  // Run app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new StateContainer(child: new DefiChainWalletApp()));
  });
}

class DefiChainWalletApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DefiChainWalletAppState();
}

class _DefiChainWalletAppState extends State<DefiChainWalletApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('de', '')
        ],
        locale: StateContainer.of(context).curLanguage == null ||
            StateContainer.of(context).curLanguage.language == AvailableLanguage.DEFAULT ? null : StateContainer.of(context).curLanguage.getLocale(),
        title: "DeFiChain Wallet",
        theme: ThemeData(
          primaryColor: StateContainer.of(context).curTheme.primary,
          backgroundColor: StateContainer.of(context).curTheme.backgroundColor,
          buttonColor: StateContainer.of(context).curTheme.backgroundColor,
          brightness: StateContainer.of(context).curTheme.brightness,
          fontFamily: 'Helvetica, Arial, sans-serif',
        ),
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch(settings.name) {
            case '/':
              return NoTransitionRoute(
                builder: (_) => SplashScreen(),
                settings: settings,
              );
              break;

            case '/home':
              return NoTransitionRoute(
                builder: (_) => HomeScreen(),
                settings: settings,
              );
              break;

            case '/intro_welcome':
              return NoTransitionRoute(
                builder: (_) => IntroWelcomeScreen(),
                settings: settings,
              );
              break;

            case '/intro_wallet_restore':
              return NoTransitionRoute(
                builder: (_) => IntroRestoreScreen(),
                settings: settings,
              );
            default:
              return null;
          }
        }
      );
  }
}
