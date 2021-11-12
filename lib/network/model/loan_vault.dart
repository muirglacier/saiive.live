import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanVault {
  final String vaultId;
  final LoanSchema schema;
  final String ownerAddress;
  final String state;
  final String informativeRatio;
  final String collateralRatio;
  final String collateralValue;
  final String loanValue;
  final String interestValue;
  final List<LoanVaultAmount> collateralAmounts;
  final List<LoanVaultAmount> loanAmounts;
  final List<LoanVaultAmount> interestAmounts;

  LoanVault(
      {this.vaultId,
      this.schema,
      this.ownerAddress,
      this.state,
      this.informativeRatio,
      this.collateralRatio,
      this.collateralValue,
      this.loanValue,
      this.interestValue,
      this.collateralAmounts,
      this.loanAmounts,
      this.interestAmounts});

  factory LoanVault.fromJson(Map<String, dynamic> json) {
    return LoanVault(
        vaultId: json['vaultId'],
        schema: json['schema'],
        ownerAddress: json['ownerAddress'],
        state: json['state'],
        informativeRatio: json['informativeRatio'],
        collateralRatio: json['collateralRatio'],
        collateralValue: json['collateralValue'],
        loanValue: json['loanValue'],
        interestValue: json['interestValue'],
        collateralAmounts: json['collateralAmounts']
            .map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data))
            .toList(),
        loanAmounts: json['loanAmounts']
            .map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data))
            .toList(),
        interestAmounts: json['interestAmounts']
            .map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data))
            .toList());
  }
}
