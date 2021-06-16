import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/input_controller.dart';
import 'package:local_auth/local_auth.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'base_unlock_handler.dart';

class MobileUnlockHandler extends BaseUnlockHandler {
  String _validPin;

  Future<bool> _localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(localizedReason: 'Please authenticate', biometricOnly: true);
    if (didAuthenticate) {
      Navigator.pop(context);
    }
    return didAuthenticate;
  }

  @override
  Future<String> setNewPassword(BuildContext context, {bool canCancel = true}) async {
    final inputController = InputController();

    await screenLock<void>(
        context: context,
        correctString: '',
        confirmation: true,
        canCancel: canCancel,
        digits: BaseUnlockHandler.PIN_LENGTH,
        inputController: inputController,
        didConfirmed: (matchedText) {
          Navigator.of(context).pop();
        },
        footer: TextButton(
          onPressed: () {
            // Release the confirmation state and return to the initial input state.
            inputController.unsetConfirmed();
          },
          child: const Text('Return enter mode.'),
        ),
        customizedButtonChild: Icon(Icons.fingerprint),
        customizedButtonTap: () async {
          await _localAuth(context);
        });

    if (inputController.confirmedInput.isNotEmpty) {
      await sl.get<SharedPrefsUtil>().setPasswordHash(hashPassword(inputController.confirmedInput));

      return inputController.confirmedInput;
    }
    return null;
  }

  @override
  Future<bool> unlockScreen(BuildContext context, {bool canCancel = true}) async {
    if (!await hasUnlockScreenEnabled()) {
      return true;
    }

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
