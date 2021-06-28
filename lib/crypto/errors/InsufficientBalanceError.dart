import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/network/model/transaction.dart';

class InsufficientBalanceError extends TransactionError {
  InsufficientBalanceError(String error, String txHex) : super(error: error, txHex: txHex);

  @override
  String copyText() {
    return error + " " + txHex;
  }
}
