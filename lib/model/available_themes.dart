import 'package:flutter/material.dart';
import 'package:defichainwallet/themes.dart';
import 'package:defichainwallet/model/setting_item.dart';

enum ThemeOptions { DEFI_LIGHT, DEFI_DARK }

class ThemeSetting extends SettingSelectionItem {
  ThemeOptions theme;
  ThemeSetting(this.theme);

  String getDisplayName(BuildContext context) {
    switch (theme) {
      case ThemeOptions.DEFI_DARK:
        return "Defi Dark";

    case ThemeOptions.DEFI_LIGHT:
      default:
        return "Defi Light";

    }
  }

  BaseTheme getTheme() {
    switch (theme) {
      case ThemeOptions.DEFI_LIGHT:
        return DefiThemeLight();
      case ThemeOptions.DEFI_DARK:
      default:
        return DefiThemeDark();
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return theme.index;
  }
}
