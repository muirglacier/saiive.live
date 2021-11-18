import 'package:saiive.live/network/model/loan_vault_price_oracles.dart';

class LoanVaultPrice {
  final double amount;
  final int weightage;
  final LoanVaultPriceOracles oracles;

  LoanVaultPrice({
    this.amount,
    this.weightage,
    this.oracles,
  });

  factory LoanVaultPrice.fromJson(Map<String, dynamic> json) {
    return LoanVaultPrice(
      amount: double.tryParse(json['amount']),
      weightage: json['weightage'],
      oracles: LoanVaultPriceOracles.fromJson(json['oracles']),
    );
  }
}
