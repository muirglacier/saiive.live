import 'package:saiive.live/network/model/transaction.dart';

import 'TransactionError.dart';

class InputValueEqualsTotalValueError extends TransactionError {
  final List<Transaction> inputTxs;
  final String to;
  final int amount;
  final int fees;
  final String changeAddress;

  InputValueEqualsTotalValueError(String error, this.inputTxs, this.to, this.amount, this.fees, this.changeAddress) : super(error: error, txHex: "");

  @override
  String copyText() {
    var copyText = "InputTx:";
    copyText += "\n\r";

    for (final tx in inputTxs) {
      final addr = tx.address;
      final mintId = tx.mintTxId;
      final mintHeight = tx.mintHeight;
      final value = tx.value;
      copyText += "Address: $addr, MintId: $mintId, MintHeight: $mintHeight, Value: $value";
      copyText += "\n\r";
    }

    copyText += "\n\r";
    copyText += "\n\r";
    copyText += "Amount: $amount, To: $to, Fees: $fees, ChangeAddress: $changeAddress";
    copyText += "\n\r";
    copyText += "\n\r";

    copyText += "Error:";
    copyText += "\n\r";
    copyText += "$error";

    copyText += "\n\r";
    copyText += "\n\r";

    return copyText;
  }
}
