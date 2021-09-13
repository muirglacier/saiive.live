import 'package:saiive.live/crypto/errors/TransactionError.dart';

class NoUtxoError extends TransactionError {
  NoUtxoError() : super(error: "", txHex: "");

  @override
  String copyText() {
    return "";
  }
}
