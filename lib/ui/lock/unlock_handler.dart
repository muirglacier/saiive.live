import 'package:flutter/cupertino.dart';

abstract class IUnlockHandler {
  Future<bool> unlockScreen(BuildContext context, {bool canCancel = true});
  Future<bool> hasUnlockScreenEnabled();

  Future<String> getUnlockCode();
  Future<String> setNewPassword(BuildContext context, {bool canCancel = true});
}
