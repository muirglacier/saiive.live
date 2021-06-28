import 'package:flutter/foundation.dart';

abstract class TransactionError extends Error {
  final String error;
  final String txHex;

  TransactionError({@required this.error, @required this.txHex});

  String copyText();

  @override
  String toString() {
    return copyText();
  }
}
