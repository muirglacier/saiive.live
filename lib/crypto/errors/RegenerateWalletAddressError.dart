import 'package:flutter/widgets.dart';

class RegenerateWalletAddressError extends Error {
  final String error;
  final String debugInfo;

  RegenerateWalletAddressError({@required this.error, @required this.debugInfo});

  String copyText() {
    return error + "\r\n" + debugInfo + "\r\n";
  }

  @override
  String toString() {
    return copyText();
  }
}
