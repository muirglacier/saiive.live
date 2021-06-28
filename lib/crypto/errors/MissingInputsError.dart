import 'package:saiive.live/crypto/errors/TransactionError.dart';

class MissingInputsError extends TransactionError {
  MissingInputsError(String error, String txHex) : super(error: error, txHex: txHex);

  @override
  String copyText() {
    return error + " " + txHex;
  }
}
