import 'package:saiive.live/appstate_container.dart';
import 'package:flutter/material.dart';

class Navigated extends StatefulWidget {
  final navigationKey = GlobalKey();
  final scaffoldKey = GlobalKey();
  final Widget child;

  Navigated({this.child});

  @override
  State<StatefulWidget> createState() {
    return _Navigated();
  }
}

class _Navigated extends State<Navigated> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      body: Container(
          color: StateContainer.of(context).curTheme.cardBackgroundColor,
          child: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (BuildContext context) {
                  return widget.child;
                },
              );
            },
          )),
    );
  }
}
