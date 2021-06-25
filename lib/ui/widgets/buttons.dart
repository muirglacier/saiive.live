import 'package:flutter/material.dart';

import '../../appstate_container.dart';

enum AppButtonType {
  PRIMARY,
  SECONDARY,
}

class AppButton {
  // Primary button builder
  static Widget buildAppButton(BuildContext context, AppButtonType type, String buttonText,
      {Function onPressed, IconData icon = null, double width = 300, bool enabled = true, Key key}) {
    switch (type) {
      case AppButtonType.PRIMARY:
        return SizedBox(
            width: width,
            child: ElevatedButton(
              key: key,
              style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorPrimary),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                if (icon != null) Icon(icon, color: StateContainer.of(context).curTheme.text),
                SizedBox(width: 10),
                Text(
                  buttonText,
                  style: TextStyle(color: StateContainer.of(context).curTheme.text),
                ),
              ]),
              onPressed: enabled
                  ? () {
                      if (onPressed != null) {
                        onPressed();
                      }
                      return;
                    }
                  : null,
            ));
      case AppButtonType.SECONDARY:
        return SizedBox(
            width: width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: StateContainer.of(context).curTheme.buttonColorSecondary),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  if (icon != null) Icon(icon, color: StateContainer.of(context).curTheme.lightColor),
                  SizedBox(width: 10),
                  Text(
                    buttonText,
                    style: TextStyle(color: StateContainer.of(context).curTheme.lightColor),
                  ),
                ]),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  }
                  return;
                }));
      default:
        return SizedBox();
    }
  } //
}
