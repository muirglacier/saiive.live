import 'package:saiive.live/crypto/errors/TransactionError.dart';

class MemPoolConflictError extends TransactionError {
  MemPoolConflictError(String error) : super(error: error);
}
