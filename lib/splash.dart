import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'generated/l10n.dart';
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

  @override
  void initState() {
    super.initState();
    _loadVersion();
    Timer(
        Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen())));
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
            style: TextStyle(fontSize: 30, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800), 
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
