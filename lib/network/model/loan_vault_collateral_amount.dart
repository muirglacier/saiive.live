import 'package:saiive.live/network/model/loan_vault_active_price.dart';

class LoanVaultAmount {
  final String id;
  String amount;
  final String symbol;
  final String symbolKey;
  final String name;
  final String displaySymbol;
  final LoanVaultActivePrice activePrice;

  LoanVaultAmount({this.id, this.amount, this.symbol, this.symbolKey, this.name, this.displaySymbol, this.activePrice});

  double get amountDouble {
    return double.tryParse(this.amount);
  }

  double get valueUSD {
    var price = this.activePrice != null ? this.activePrice.active.amount : 1;

    return amountDouble * price;
  }

  double get valueUSDNext {
    var price = this.activePrice != null ? this.activePrice.next.amount : 1;

    return amountDouble * price;
  }

  factory LoanVaultAmount.fromJson(Map<String, dynamic> json) {
    return LoanVaultAmount(
        id: json['id'],
        amount: json['amount'],
        symbol: json['symbol'],
        symbolKey: json['symbolKey'],
        name: json['name'],
        displaySymbol: json['displaySymbol'],
        activePrice: json.containsKey("activePrice") && json["activePrice"] != null ? LoanVaultActivePrice.fromJson(json['activePrice']) : null);
  }
}
