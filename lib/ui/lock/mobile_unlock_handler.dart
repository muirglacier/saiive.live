import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/input_controller.dart';
import 'package:local_auth/local_auth.dart';
import 'package:saiive.live/appstate_container.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/env_service.dart';
import 'package:saiive.live/ui/model/authentication_method.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'base_unlock_handler.dart';

class MobileUnlockHandler extends BaseUnlockHandler {
  String _validPin;

  Future<bool> _localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(localizedReason: S.of(context).authenticate, stickyAuth: true, sensitiveTransaction: false);
    if (didAuthenticate) {
      Navigator.pop(context);
    }
    return didAuthenticate;
  }

  @override
  Future<String> setNewPassword(BuildContext context, {bool canCancel = true}) async {
    final inputController = InputController();

    var authMethod = AuthMethod.NONE;
    await screenLock<void>(
      context: context,
      correctString: '',
      confirmation: true,
      canCancel: canCancel,
      digits: BaseUnlockHandler.PIN_LENGTH,
      inputController: inputController,
      confirmTitle: Text(S.of(context).pin_confirm),
      title: Text(S.of(context).pin_enter),
      didConfirmed: (matchedText) {
        Navigator.of(context).pop();
      },
      footer: TextButton(
        onPressed: () {
          // Release the confirmation state and return to the initial input state.
          inputController.unsetConfirmed();
        },
        child: Text(S.of(context).pin_return),
      ),
      // customizedButtonChild: Icon(Icons.fingerprint),
      // customizedButtonTap: () async {
      //   usedFingerprint = await _localAuth(context);
      //   authMethod = AuthMethod.BIOMETRICS;
      // }
    );

    if (inputController.confirmedInput.isNotEmpty) {
      await sl.get<SharedPrefsUtil>().setPasswordHash(hashPassword(inputController.confirmedInput));
      authMethod = AuthMethod.PIN;
      await sl.get<SharedPrefsUtil>().setUseAuthentiaction(authMethod);

      return inputController.confirmedInput;
    }
    throw new ArgumentError("something bad happened");
  }

  @override
  Future<bool> unlockScreen(BuildContext context, {bool canCancel = true}) async {
    final env = await sl.get<IEnvironmentService>().getCurrentEnvironment();

    if (env == EnvironmentType.Development) {
      return true;
    }

    if (!await hasUnlockScreenEnabled()) {
      return true;
    }
    final translate = S.of(context);
    final inputController = InputController();
    var isValidated = false;

    inputController.currentInput.listen((event) async {
      if (event.isEmpty) {
        return;
      }
      if (await isValid(event)) {
        inputController.verifyController.add(true);
        isValidated = true;
        _validPin = event;
      } else {
        if (event.length == BaseUnlockHandler.PIN_LENGTH) {
          inputController.verifyController.add(false);
        }
      }
    });
    await screenLock(
        context: context,
        correctString: "",
        confirmTitle: Text(translate.pin_confirm),
        title: Text(translate.pin_enter),
        inputController: inputController,
        canCancel: canCancel,
        digits: BaseUnlockHandler.PIN_LENGTH,
        customizedButtonChild: Icon(Icons.fingerprint),
        customizedButtonTap: () async {
          isValidated = await _localAuth(context);
        });

    return isValidated;
  }

  @override
  Future<String> getUnlockCode() {
    return Future.value(_validPin);
  }
}
