import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/crypto/chain.dart';
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
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger_flutter/logger_flutter.dart';

void run() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

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
  ChainNet _network;

  void init() async {
    final network = await sl.get<SharedPrefsUtil>().getChainNetwork();
    setState(() {
      _network = network;
    });

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
        title: "DeFiChain Wallet",
        theme: ThemeData(
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
                builder: (_) => RestoreAccountsScreen(ChainType.DeFiChain, _network),
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
