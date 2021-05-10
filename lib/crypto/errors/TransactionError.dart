import 'package:flutter/foundation.dart';

abstract class TransactionError extends Error {
  final String error;

  TransactionError({@required this.error});
}
