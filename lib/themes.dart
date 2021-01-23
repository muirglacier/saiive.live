import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Some constants not themed
  static const overlay70 = Color(0xB3000000);
  static const overlay85 = Color(0xD9000000);
}

abstract class BaseTheme {
  Color primary;
  Color primary60;
  Color primary45;
  Color primary30;
  Color primary20;
  Color primary15;
  Color primary10;

  Color accent;
  Color accent60;
  Color accent45;
  Color accent30;
  Color accent20;
  Color accent15;
  Color accent10;

  Color success;
  Color success60;
  Color success30;
  Color success15;
  Color successDark;
  Color successDark30;

  Color background;
  Color background40;
  Color background00;

  Color backgroundDark;
  Color backgroundDark00;

  Color backgroundDarkest;

  Color text;
  Color text60;
  Color text45;
  Color text30;
  Color text20;
  Color text15;
  Color text10;
  Color text5;
  Color text03;

  Color overlay90;
  Color overlay85;
  Color overlay80;
  Color overlay70;
  Color overlay50;
  Color overlay30;
  Color overlay20;

  Color animationOverlayMedium;
  Color animationOverlayStrong;

  Brightness brightness;
  SystemUiOverlayStyle statusBar;

  BoxShadow boxShadow;
  BoxShadow boxShadowButton;
}

class DefiTheme extends BaseTheme {
  static const pink = Color.fromARGB(0xFF, 0xFF, 0x00, 0xAF);
  static const yellow = Color.fromARGB(0xFF, 0xFF, 0xFF, 0x7F);

  static const green = Color(0xFF4CBF4B);
  static const greenDark = Color(0xFF276126);
  static const greyLight = Color(0xFF2A2A2E);
  static const greyDark = Color(0xFF212124);
  static const greyDarkest = Color(0xFF1A1A1C);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  Color primary = pink;
  Color primary60 = pink.withOpacity(0.6);
  Color primary45 = pink.withOpacity(0.45);
  Color primary30 = pink.withOpacity(0.3);
  Color primary20 = pink.withOpacity(0.2);
  Color primary15 = pink.withOpacity(0.15);
  Color primary10 = pink.withOpacity(0.1);

  Color accent = yellow;
  Color accent60 = yellow.withOpacity(0.6);
  Color accent45 = yellow.withOpacity(0.45);
  Color accent30 = yellow.withOpacity(0.3);
  Color accent20 = yellow.withOpacity(0.2);
  Color accent15 = yellow.withOpacity(0.15);
  Color accent10 = yellow.withOpacity(0.1);

  Color success = green;
  Color success60 = green.withOpacity(0.6);
  Color success30 = green.withOpacity(0.3);
  Color success15 = green.withOpacity(0.15);

  Color successDark = greenDark;
  Color successDark30 = greenDark.withOpacity(0.3);

  Color background = greyLight;
  Color background40 = greyLight.withOpacity(0.4);
  Color background00 = greyLight.withOpacity(0.0);

  Color backgroundDark = greyDark;
  Color backgroundDark00 = greyDark.withOpacity(0.0);

  Color backgroundDarkest = greyDarkest;

  Color text = white.withOpacity(0.9);
  Color text60 = white.withOpacity(0.6);
  Color text45 = white.withOpacity(0.45);
  Color text30 = white.withOpacity(0.3);
  Color text20 = white.withOpacity(0.2);
  Color text15 = white.withOpacity(0.15);
  Color text10 = white.withOpacity(0.1);
  Color text05 = white.withOpacity(0.05);
  Color text03 = white.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Color animationOverlayMedium = black.withOpacity(0.7);
  Color animationOverlayStrong = black.withOpacity(0.85);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);
}
