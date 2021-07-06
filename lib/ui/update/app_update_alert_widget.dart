import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mutex/mutex.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/events/wallet_sync_done_event.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateAlert extends StatefulWidget {
  final Widget child;

  AppUpdateAlert({@required this.child});

  @override
  State<StatefulWidget> createState() => _AppUpdateAlert();
}

class _AppUpdateAlert extends State<AppUpdateAlert> {
  StreamSubscription<WalletSyncDoneEvent> _walletSyncDoneSubscription;
  AppUpdateInfo _updateInfo;
  bool popupVisible = false;
  Mutex _mutex = Mutex();

  bool _initDone = false;

  Future<bool> init() async {
    if (_initDone) {
      return true;
    }

    _initDone = true;

    await getVersionInfos();
    return true;
  }

  getVersionInfos() async {
    try {
      if (EnvHelper.getEnvironment() != EnvironmentType.Development) {
        _updateInfo = await InAppUpdate.checkForUpdate();
      }
    } catch (e) {
      LogHelper.instance.e(e.toString());
    } finally {}
  }

  @override
  initState() {
    super.initState();
    if (_walletSyncDoneSubscription == null) {
      _walletSyncDoneSubscription = EventTaxiImpl.singleton().registerTo<WalletSyncDoneEvent>().listen((event) async {
        if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
          await showAndroidDialog();
        }

        _walletSyncDoneSubscription.cancel();
        _walletSyncDoneSubscription = null;
      });
    }
  }

  @override
  dispose() {
    if (popupVisible) {
      Navigator.of(context).pop();
    }

    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_walletSyncDoneSubscription != null) {
      _walletSyncDoneSubscription.cancel();
      _walletSyncDoneSubscription = null;
    }
  }

  showAndroidDialog() async {
    if (_mutex.isLocked) {
      return;
    }

    await _mutex.acquire();

    if (popupVisible) {
      return;
    }

    try {
      var cancelButton = ElevatedButton(
        child: Text(S.of(context).update_start),
        onPressed: () async {
          try {
            await InAppUpdate.performImmediateUpdate();
          } finally {
            Navigator.of(context).pop();
          }
        },
      );
      var continueButton = ElevatedButton(
        child: Text(S.of(context).update_cancel),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text(S.of(context).update_title),
        content: Text(S.of(context).update_text(S.of(context).title)),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      popupVisible = true;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );

      popupVisible = false;
    } finally {
      _mutex.release();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UpgradeAlert(
          child: Center(
            child: widget.child,
          ),
          debugLogging: true,
          canDismissDialog: false,
          showIgnore: false);
    }

    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<bool> processed) {
          if (processed.connectionState == ConnectionState.done) {}
          return widget.child;
        });
  }
}
