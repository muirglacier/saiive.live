import 'package:defichainwallet/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _brightness = Brightness.dark;

  void loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(DefiChainConstants.ThemeBrightness)) {
      prefs.setInt(DefiChainConstants.ThemeBrightness, Brightness.light.index);
    }
    setState(() {
      _brightness =
          Brightness.values[prefs.getInt(DefiChainConstants.ThemeBrightness)];
    });
  }

  @override
  void initState() {
    super.initState();

    loadThemeSettings();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var isDark = _brightness == Brightness.dark;
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
        title: "DeFiChain Wallet",
        theme: ThemeData(
          brightness: _brightness,
          primaryColor: Color.fromARGB(0xFF, 0xFF, 0x00, 0xAF),
          accentColor: Color.fromARGB(0xFF, 0xFF, 0xFF, 0x7F),
          backgroundColor: isDark ? Colors.black : Colors.white,

          fontFamily: 'Helvetica, Arial, sans-serif',
        ),
        home: SplashScreen());
  }
}
