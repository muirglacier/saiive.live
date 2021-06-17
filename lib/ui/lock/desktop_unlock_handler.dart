import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/input_controller.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/model/authentication_method.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

import 'base_unlock_handler.dart';

class DesktopUnlockHandler extends BaseUnlockHandler {
  String _validPin;

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
    await screenLock(context: context, correctString: "", inputController: inputController, canCancel: canCancel, digits: BaseUnlockHandler.PIN_LENGTH);

    return isValidated;
  }

  @override
  Future<String> getUnlockCode() {
    return Future.value(_validPin);
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
    );

    if (inputController.confirmedInput.isNotEmpty) {
      await sl.get<SharedPrefsUtil>().setPasswordHash(hashPassword(inputController.confirmedInput));
      await sl.get<SharedPrefsUtil>().setUseAuthentiaction(AuthMethod.PIN);

      _validPin = inputController.confirmedInput;
      return inputController.confirmedInput;
    }
    return null;
  }
}
