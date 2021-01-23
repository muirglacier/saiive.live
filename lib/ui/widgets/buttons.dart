import 'package:flutter/material.dart';

import '../../appstate_container.dart';

enum AppButtonType {
  PRIMARY,
  SECONDARY,
}

class AppButton {
  // Primary button builder
  static Widget buildAppButton(BuildContext context, AppButtonType type,
      String buttonText, {Function onPressed, IconData icon = null}) {
    switch (type) {
      case AppButtonType.PRIMARY:
        return SizedBox(
            width: 300,
            child: RaisedButton(
                color: StateContainer.of(context).curTheme.buttonColorPrimary,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) Icon(icon,
                          color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        buttonText,
                      ),
                    ]),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  }
                  return;
                }));
      case AppButtonType.SECONDARY:
        return SizedBox(
            width: 300,
            child: RaisedButton(
                color: StateContainer.of(context).curTheme.buttonColorSecondary,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) Icon(icon,
                          color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        buttonText,
                      ),
                    ]),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  }
                  return;
                }));
        
        throw new UnsupportedError('Button not implemented');
    }
  } //
}
