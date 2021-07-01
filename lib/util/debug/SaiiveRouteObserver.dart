import 'package:flutter/material.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/ui/utils/routes.dart';

class SaiiveRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    var screenName = route.settings.name;

    if (route is NoTransitionRoute) {
      LogHelper.instance.d("[Navigation] RouteName: $screenName Route to " + route.builder.toString());
    }

    // do something with it, ie. send it to your analytics service collector
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
