import 'package:defichainwallet/ui/model/settings_item.dart';
import 'package:flutter/material.dart';
import 'package:defichainwallet/themes.dart';

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


  static List<ThemeSetting> all() {
    return [
      new ThemeSetting(ThemeOptions.DEFI_LIGHT),
      new ThemeSetting(ThemeOptions.DEFI_DARK),
    ];
  }

  // For saving to shared prefs
  int getIndex() {
    return theme.index;
  }
}
