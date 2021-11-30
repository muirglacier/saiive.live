import 'package:saiive.live/crypto/errors/TransactionError.dart';

class PriceHigherThanIndicatedError extends TransactionError {
  PriceHigherThanIndicatedError(String error, String txHex) : super(error: error, txHex: txHex);

  @override
  String copyText() {
    return error + " " + txHex;
  }
}
