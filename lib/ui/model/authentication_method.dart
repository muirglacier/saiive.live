import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/ui/model/settings_item.dart';
import 'package:flutter/material.dart';

enum AuthMethod { NONE, BIOMETRICS, PIN }

class AuthenticationMethod extends SettingSelectionItem {
  AuthMethod method = AuthMethod.NONE;

  AuthenticationMethod(this.method);

  String getDisplayName(BuildContext context) {
    switch (method) {
      case AuthMethod.BIOMETRICS:
        return S.of(context).settings_auth_biometric;
      case AuthMethod.PIN:
        return S.of(context).settings_auth_biometric;
      case AuthMethod.NONE:
      default:
        return S.of(context).settings_auth_none;
    }
  }

  static List<AuthenticationMethod> all() {
    return [
      new AuthenticationMethod(AuthMethod.NONE),
      new AuthenticationMethod(AuthMethod.BIOMETRICS),
      new AuthenticationMethod(AuthMethod.PIN),
    ];
  }

  // For saving to shared prefs
  int getIndex() {
    return method.index;
  }
}
