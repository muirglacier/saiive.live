import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/channel.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/navigation.helper.dart';
import 'package:saiive.live/push/notification_badge_widget.dart';
import 'package:saiive.live/push/push_notification_received_event.dart';
import 'package:saiive.live/push/push_service.dart';
import 'package:saiive.live/services/background.dart';
import 'package:saiive.live/ui/model/available_language.dart';
import 'package:saiive.live/ui/intro/intro_wallet_new.dart';
import 'package:saiive.live/ui/splash.dart';
import 'package:saiive.live/ui/home.dart';
import 'package:saiive.live/ui/intro/intro_welcome.dart';
import 'package:saiive.live/ui/intro/intro_restore.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/utils/routes.dart';
import 'package:saiive.live/ui/widgets/restore_accounts.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger_flutter_console/logger_flutter_console.dart';
import 'package:saiive.live/util/debug/SaiiveRouteObserver.dart';
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
    runZonedGuarded(() async {
      runApp(new StateContainer(child: new SaiiveLiveApp())); // starting point of app
    }, (error, stackTrace) {
      LogHelper.instance.e("Unhandled Error!", error, stackTrace);
      print("Error FROM OUT_SIDE FRAMEWORK ");
      print("--------------------------------");
      print("Error :  $error");
      print("StackTrace :  $stackTrace");
    });
  });
}

class SaiiveLiveApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SaiiveLiveAppState();
}

class _SaiiveLiveAppState extends State<SaiiveLiveApp> {
  final ChannelConnection connection = new ChannelConnection();

  void init() {
    LogConsole.init(bufferSize: 200);

    Logger.addLogListener((e) {
      try {
        if (e.level == Level.error) {
          sl.get<AppCenterWrapper>().trackEvent("logger", <String, String>{
            'message': e.message,
            'error': e.error,
            'stackTrace': e.stackTrace.toString(),
          });
        }
      } catch (e) {}
      //ignore
    });
  }

  @override
  void initState() {
    super.initState();

    EventTaxiImpl.singleton().registerAll().listen((event) {
      final eventType = event.runtimeType.toString();
      StateContainer.of(context).appCenter.trackEvent(eventType, {});
      StateContainer.of(context).logger.d("Event " + eventType + " called...");
    });

    sl.get<ChannelConnection>().init();

    EventTaxiImpl.singleton().registerTo<PushNotificationReceivedEvent>().listen((event) async {
      StateContainer.of(context).logger.i("PushNotification " + event.toString() + " called...");

      showSimpleNotification(
        Text(event.notification.title),
        leading: NotificationBadge(event.notification.title, event.notification.body),
        subtitle: Text(event.notification.body),
        background: Colors.cyan.shade700,
        duration: Duration(seconds: 10),
      );
    });
    final pushService = sl.get<IPushService>();
    pushService.registerPushService().then((value) async {
      await pushService.checkForInitialMessage();
    });

    sl.get<BackgroundService>().start();
    init();
  }

  @override
  void dispose() {
    super.dispose();
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

    return OverlaySupport(
        child: MaterialApp(
            navigatorKey: NavigationHelper.navigatorKey,
            navigatorObservers: [SaiiveRouteObserver()],
            debugShowCheckedModeBanner: dotenv.env["ENV"] == "dev",
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en', ''), const Locale('de', ''), const Locale('es', '')],
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
                elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.primary)),
                textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: StateContainer.of(context).curTheme.primary)),
                textSelectionTheme:
                    TextSelectionThemeData(cursorColor: StateContainer.of(context).curTheme.primary, selectionHandleColor: StateContainer.of(context).curTheme.primary),
                inputDecorationTheme: InputDecorationTheme(
                    counterStyle: TextStyle(color: StateContainer.of(context).curTheme.primary),
                    focusColor: StateContainer.of(context).curTheme.primary,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid, color: StateContainer.of(context).curTheme.primary)))),
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
            }));
  }
}
