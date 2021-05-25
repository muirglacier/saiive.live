import 'dart:io';

import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/ui/model/available_language.dart';
import 'package:defichainwallet/ui/intro/intro_wallet_new.dart';
import 'package:defichainwallet/ui/splash.dart';
import 'package:defichainwallet/ui/home.dart';
import 'package:defichainwallet/ui/intro/intro_welcome.dart';
import 'package:defichainwallet/ui/intro/intro_restore.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/ui/utils/routes.dart';
import 'package:defichainwallet/ui/widgets/restore_accounts.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:window_size/window_size.dart';

const String APP_TITLE = "saiive.live";

void run() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(APP_TITLE);
    setWindowMinSize(const Size(700, 500));
    setWindowMaxSize(Size.infinite);
  }

  // Run app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new StateContainer(child: new DefiChainWalletApp()));
  });
}

class DefiChainWalletApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DefiChainWalletAppState();
}

class _DefiChainWalletAppState extends State<DefiChainWalletApp> {
  void init() {
    LogConsole.init();
  }

  @override
  void initState() {
    super.initState();

    EventTaxiImpl.singleton().registerAll().listen((event) {
      final eventType = event.runtimeType.toString();
      StateContainer.of(context).appCenter.trackEvent(eventType, {});
      StateContainer.of(context).logger.d("Event " + eventType + " called...");
    });

    init();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var shadowColor = Colors.black;
    var appBarColor = StateContainer.of(context).curTheme.primary;
    var appBarTextColor = StateContainer.of(context).curTheme.appBarText;
    var appBarActionColor = Colors.white;

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      shadowColor = Colors.transparent;
      appBarColor = StateContainer.of(context).curTheme.lightColor;
      appBarTextColor = StateContainer.of(context).curTheme.primary;
      appBarActionColor = StateContainer.of(context).curTheme.primary;

      StateContainer.of(context).curTheme.toolbarHeight = 80;
    }

    ThemeData theme = ThemeData();

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
        locale: StateContainer.of(context).curLanguage == null || StateContainer.of(context).curLanguage.language == AvailableLanguage.DEFAULT
            ? null
            : StateContainer.of(context).curLanguage.getLocale(),
        title: APP_TITLE,
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: appBarColor,
              shadowColor: shadowColor,
              iconTheme: IconThemeData(color: appBarActionColor),
              foregroundColor: appBarTextColor,
              actionsIconTheme: IconThemeData(color: appBarTextColor),
              toolbarTextStyle: TextStyle(color: appBarTextColor, fontWeight: FontWeight.bold),
              titleTextStyle: TextStyle(color: appBarTextColor, fontWeight: FontWeight.bold),
              textTheme: theme.textTheme.copyWith(
                headline6: theme.textTheme.headline6.copyWith(color: appBarTextColor, fontSize: 20.0),
              ),
            ),
            brightness: StateContainer.of(context).curTheme.brightness,
            primaryColor: StateContainer.of(context).curTheme.primary,
            scaffoldBackgroundColor: StateContainer.of(context).curTheme.backgroundColor,
            canvasColor: StateContainer.of(context).curTheme.backgroundColor,
            textTheme: TextTheme(
                headline3: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: StateContainer.of(context).curTheme.text,
                ),
                bodyText1: TextStyle(
                  color: StateContainer.of(context).curTheme.text,
                ),
                bodyText2: TextStyle(
                  color: StateContainer.of(context).curTheme.text,
                )),
            buttonColor: StateContainer.of(context).curTheme.primary,
            fontFamily: 'Helvetica, Arial, sans-serif',
            tabBarTheme: TabBarTheme(labelColor: appBarTextColor),
            elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary))),
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
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
            case '/intro_accounts_restore':
              return NoTransitionRoute(
                builder: (_) => RestoreAccountsScreen(),
                settings: settings,
              );
            case '/intro_wallet_new':
              return NoTransitionRoute(
                builder: (_) => IntroWalletNewScreen(),
                settings: settings,
              );
            default:
              return null;
          }
        });
  }
}
