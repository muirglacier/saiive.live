import 'package:saiive.live/crypto/errors/TransactionError.dart';

class MemPoolConflictError extends TransactionError {
  MemPoolConflictError(String error, String txHex) : super(error: error, txHex: txHex);

  @override
  String copyText() {
    return error + " " + txHex;
  }
}
