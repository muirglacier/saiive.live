import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateAlert extends StatefulWidget {
  final Widget child;

  AppUpdateAlert({@required this.child});

  @override
  State<StatefulWidget> createState() => _AppUpdateAlert();
}

class _AppUpdateAlert extends State<AppUpdateAlert> {
  AppUpdateInfo _updateInfo;
  bool popupVisible = false;

  checkForUpdates() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        await showAndroidDialog();
      }
    } catch (e) {
      LogHelper.instance.e(e.toString());
    } finally {}
    await showAndroidDialog();
  }

  @override
  initState() {
    super.initState();
    if (Platform.isAndroid) {
      checkForUpdates();
    }
  }

  showAndroidDialog() async {
    if (popupVisible) {
      return;
    }
    var cancelButton = ElevatedButton(
      child: Text(S.of(context).ok),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    var continueButton = ElevatedButton(
      child: Text(S.of(context).cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    popupVisible = true;
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    popupVisible = false;
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

    return widget.child;
  }
}
