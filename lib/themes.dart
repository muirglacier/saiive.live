import 'dart:io';
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
  static const white = Color(0x00000000);

  Color primary;
  Color background;
  Color text;

  Brightness brightness = Brightness.light;
}

class DefiThemeLight extends BaseTheme {
  Color primary = BaseTheme.pink;
  Color background = BaseTheme.white;
  Color text = BaseTheme.black;

  Brightness brightness = Brightness.light;
}

class DefiThemeDark extends BaseTheme {
  Color primary = BaseTheme.pink;
  Color background = BaseTheme.black;
  Color text = BaseTheme.white;

  Brightness brightness = Brightness.dark;
}