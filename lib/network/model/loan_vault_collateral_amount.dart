import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/helper/constants.dart';

class LoanVaultAmount {
  final String id;
  final String amount;
  final String symbol;
  final String symbolKey;
  final String name;
  final String displaySymbol;

  LoanVaultAmount(
      {this.id,
      this.amount,
      this.symbol,
      this.symbolKey,
      this.name,
      this.displaySymbol});

  factory LoanVaultAmount.fromJson(Map<String, dynamic> json) {
    return LoanVaultAmount(
        id: json['id'],
        amount: json['amount'],
        symbol: json['symbol'],
        symbolKey: json['symbolKey'],
        name: json['name'],
        displaySymbol: json['displaySymbol']);
  }
}
