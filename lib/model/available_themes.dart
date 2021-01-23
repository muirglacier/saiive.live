import 'package:flutter/material.dart';
import 'package:defichainwallet/themes.dart';
import 'package:defichainwallet/model/setting_item.dart';

enum ThemeOptions { DEFI }

class ThemeSetting extends SettingSelectionItem {
  ThemeOptions theme;
  ThemeSetting(this.theme);

  String getDisplayName(BuildContext context) {
    switch (theme) {
      case ThemeOptions.DEFI:
      default:
        return "Defi";
    }
  }

  BaseTheme getTheme() {
    switch (theme) {
      case ThemeOptions.DEFI:
      default:
        return DefiTheme();
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return theme.index;
  }
}
