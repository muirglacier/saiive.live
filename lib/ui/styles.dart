import 'package:flutter/material.dart';
import 'package:defichainwallet/appstate_container.dart';

class AppStyles {
  // Text style for paragraph text.
  static TextStyle textStyleParagraph(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.medium,
        fontWeight: FontWeight.w200,
        color: StateContainer.of(context).curTheme.text);
  }

  static TextStyle textStyleButtonPrimary(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.background);
  }

  // Text style for outline button
  static TextStyle textStyleButtonPrimaryOutline(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.primary);
  }

  static TextStyle textStyleButtonPrimaryOutlineDisabled(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.primary60);
  }

  // Green primary button
  static TextStyle textStyleButtonPrimaryGreen(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.successDark);
  }

  // Text style for success outline button
  static TextStyle textStyleButtonSuccessOutline(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.success);
  }

  // Text style for text outline button
  static TextStyle textStyleButtonTextOutline(BuildContext context) {
    return TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: FontWeight.w700,
        color: StateContainer.of(context).curTheme.text);
  }
}

class AppFontSizes {
  static const smallest = 12.0;
  static const small = 14.0;
  static const medium = 16.0;
  static const large = 24.0;
}

class ButtonDimensions {
  // Standard dimensions: left, top, right, bottom
  // Button top/bottom style
  static const BUTTON_TOP_DIMENS = [28.0, 0.0, 28.0, 8.0];
  static const BUTTON_TOP_EXCEPTION_DIMENS = [28.0, 24.0, 28.0, 8.0];
  static const BUTTON_BOTTOM_DIMENS = [28.0, 8.0, 28.0, 0.0];
  // Button left/right style
  static const BUTTON_LEFT_DIMENS = [14.0, 0.0, 7.0, 24.0];
  static const BUTTON_RIGHT_DIMENS = [7.0, 0.0, 14, 24.0];
}