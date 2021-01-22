import 'dart:async';
import 'package:defichainwallet/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'generated/l10n.dart';
import 'helper/constants.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _version = "";

  void _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    setState(() {
      _version = version + "." + buildNumber;
    });
  }

  _init() async {
    final prefs = await SharedPreferences.getInstance();
    final mnemonic = prefs.getString(DefiChainConstants.MnemonicKey);

    if (mnemonic == null || mnemonic == "") {
     Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WelcomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
                Text(S.of(context).version),
                SizedBox(width: 5),
                Text(_version)
              ])
        ],
      )),
    );
  }
}
