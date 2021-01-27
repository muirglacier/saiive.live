import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Some constants not themed
  static const overlay70 = Color(0xB3000000);
  static const overlay85 = Color(0xD9000000);
}

abstract class BaseTheme {
  static const pink = Color.fromARGB(0xFF, 0xFF, 0x00, 0xAF);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  Color primary;
  Color backgroundColor;
  Color text;

  Color buttonColorPrimary;
  Color buttonColorSecondary;

  Brightness brightness = Brightness.light;
}

class DefiThemeLight extends BaseTheme {
  Color primary = BaseTheme.pink;
  Color backgroundColor = BaseTheme.white;
  Color text = BaseTheme.black;

  Color buttonColorPrimary = BaseTheme.white;
  Color buttonColorSecondary = Colors.grey.withOpacity(0.8);

  Brightness brightness = Brightness.light;
}

class DefiThemeDark extends BaseTheme {
  Color primary = BaseTheme.pink;
  Color backgroundColor = BaseTheme.black;
  Color text = BaseTheme.white;

  Color buttonColorPrimary = BaseTheme.black;
  Color buttonColorSecondary = Colors.grey.shade50;

  Brightness brightness = Brightness.light;
}
