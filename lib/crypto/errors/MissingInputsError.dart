import 'package:saiive.live/crypto/errors/TransactionError.dart';

class MissingInputsError extends TransactionError {
  MissingInputsError(String error) : super(error: error);
}
