import 'dart:async';

import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/network/block_service.dart';
import 'package:saiive.live/network/model/block.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';

import 'package:saiive.live/themes.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/model/available_language.dart';
import 'package:saiive.live/ui/model/available_themes.dart';
import 'package:logger/logger.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';

import 'network/events/events.dart';

enum EnvironmentType { Unknonw, Development, Staging, Production }

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
    return context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>().data;
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
  BaseTheme curTheme = DefiThemeDark();
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  Locale deviceLocale = Locale('en', 'US');
  AppCenterWrapper appCenter;
  Logger get logger => LogHelper.instance;

  GlobalKey<ScaffoldState> scaffoldKey;

  bool _walletSyncing = false;

  StreamSubscription<WalletInitStartEvent> _walletInitSubscribe;
  StreamSubscription<WalletSyncStartEvent> _walletSyncSubscribe;
  StreamSubscription<WalletSyncDoneEvent> _walletSyncDoneSubscibre;

  _registerBus() {
    _walletInitSubscribe = EventTaxiImpl.singleton().registerTo<WalletInitStartEvent>().listen((event) async {
      var wallet = sl.get<IWalletService>();

      try {
        await wallet.init();
        EventTaxiImpl.singleton().fire(WalletInitDoneEvent());
      } catch (e) {
        EventTaxiImpl.singleton().fire(WalletInitDoneEvent(hasError: true, error: e));
      }
    });

    _walletSyncSubscribe = EventTaxiImpl.singleton().registerTo<WalletSyncStartEvent>().listen((event) async {
      try {
        if (_walletSyncing) {
          return;
        }
        var wallet = sl.get<IWalletService>();
        logger.i("Start wallet sync....");
        _walletSyncing = true;
        await wallet.init();
        await wallet.syncAll();
        EventTaxiImpl.singleton().fire(WalletSyncDoneEvent());
      } catch (e) {
        EventTaxiImpl.singleton().fire(WalletSyncDoneEvent(hasError: true, error: e));

        logger.e("wallet sync failed....", e);
      } finally {
        logger.i("Start wallet sync....done");
        _walletSyncing = false;
      }
    });

    _walletSyncDoneSubscibre = EventTaxiImpl.singleton().registerTo<WalletSyncDoneEvent>().listen((event) async {
      try {
        Block blockTip = await sl.get<BlockService>().getBlockTip('DFI');

        sl.get<ISharedPrefsUtil>().setLastSyncedBlock(blockTip);

        EventTaxiImpl.singleton().fire(BlockTipUpdatedEvent(block: blockTip));
      } catch (e) {
        logger.e("Error getting blocktip", e);
        await sl.get<AppCenterWrapper>().trackEvent("getBlockTipError", <String, String>{"error": e.toString()});
      }
    });
  }

  void _destroyBus() {
    if (_walletInitSubscribe != null) {
      _walletInitSubscribe.cancel();
    }
    if (_walletSyncSubscribe != null) {
      _walletSyncSubscribe.cancel();
    }

    if (_walletSyncDoneSubscibre != null) {
      _walletSyncDoneSubscibre.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    _registerBus();
    // Get theme default
    sl.get<ISharedPrefsUtil>().getTheme().then((theme) {
      updateTheme(theme);
    });

    appCenter = sl.get<AppCenterWrapper>();
    appCenter.start();
  }

  @override
  void dispose() {
    super.dispose();
    _destroyBus();
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
