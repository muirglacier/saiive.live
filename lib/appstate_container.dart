import 'dart:async';

import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/wallet/impl/wallet.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:defichainwallet/themes.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/network/model/available_language.dart';
import 'package:defichainwallet/network/model/available_themes.dart';

import 'network/events/events.dart';

class _InheritedStateContainer extends InheritedWidget {
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // You must pass through a child and your state.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  // You must pass through a child.
  final Widget child;

  StateContainer({@required this.child});

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        .data;
  }

  @override
  StateContainerState createState() => StateContainerState();
}

/// App InheritedWidget
/// This is where we handle the global state and also where
/// we interact with the server and make requests/handle+propagate responses
///
/// Basically the central hub behind the entire app
class StateContainerState extends State<StateContainer> {
  BaseTheme curTheme = DefiThemeLight();
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  Locale deviceLocale = Locale('en', 'US');
  AppCenterWrapper appCenter = AppCenterWrapper();

  Wallet wallet;

  StreamSubscription<WalletInitStartEvent> _walletInitSubscribe;
  StreamSubscription<WalletSyncStartEvent> _walletSyncSubscribe;

  _registerBus() {
    _walletInitSubscribe = EventTaxiImpl.singleton()
        .registerTo<WalletInitStartEvent>()
        .listen((event) async {
      wallet = Wallet("", 0, ChainType.DeFiChain, ChainNet.Testnet);

      try {
        await wallet.init();
        EventTaxiImpl.singleton().fire(WalletInitDoneEvent());
      } catch (e) {
        EventTaxiImpl.singleton()
            .fire(WalletInitDoneEvent(hasError: true, error: e));
      }
    });

    _walletSyncSubscribe = EventTaxiImpl.singleton()
        .registerTo<WalletSyncStartEvent>()
        .listen((event) async {
      try {
        await wallet.syncWallet();
        EventTaxiImpl.singleton().fire(WalletSyncDoneEvent());
      } catch (e) {
        EventTaxiImpl.singleton()
            .fire(WalletSyncDoneEvent(hasError: true, error: e));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _registerBus();
    // Get theme default
    sl.get<SharedPrefsUtil>().getTheme().then((theme) {
      updateTheme(theme);
    });

    appCenter.start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Change language
  void updateLanguage(LanguageSetting language) {
    setState(() {
      curLanguage = language;
      deviceLocale = deviceLocale;
    });
  }

  // Change theme
  void updateTheme(ThemeSetting theme) {
    setState(() {
      curTheme = theme.getTheme();
    });
  }

  void updateDeviceLocale(Locale locale) {
    setState(() {
      deviceLocale = locale;
    });
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}
