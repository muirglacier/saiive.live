import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

enum LoanVaultStatus {
  unknown,
  active,
  in_liquidation,
  frozen,
  may_liquidate,
}

extension ParseToStringLoanVaultStatus on LoanVaultStatus {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

enum LoanVaultHealthStatus { active, healthy, at_risk, halted, liquidated, unknown }

extension ParseToStringLoanVaultHealthStatus on LoanVaultHealthStatus {
  String toShortString() {
    return this.toString().split('.').last;
  }

  String toText() {
    switch (this) {
      case LoanVaultHealthStatus.active:
        {
          return 'ACTIVE';
        }

      case LoanVaultHealthStatus.healthy:
        {
          return 'HEALTHY';
        }

      case LoanVaultHealthStatus.at_risk:
        {
          return 'AT RISK';
        }

      case LoanVaultHealthStatus.halted:
        {
          return 'HALTED';
        }

      case LoanVaultHealthStatus.liquidated:
        {
          return 'LIQUIDATED';
        }

      case LoanVaultHealthStatus.unknown:
        break;
    }

    return 'UNKNOWN';
  }

  Color toColor() {
    switch (this) {
      case LoanVaultHealthStatus.active:
        {
          return Colors.grey;
        }

      case LoanVaultHealthStatus.healthy:
        {
          return Colors.green;
        }

      case LoanVaultHealthStatus.at_risk:
        {
          return Colors.red;
        }

      case LoanVaultHealthStatus.halted:
        {
          return Colors.deepOrange;
        }

      case LoanVaultHealthStatus.liquidated:
        {
          return Colors.blue;
        }

      case LoanVaultHealthStatus.unknown:
        break;
    }

    return Colors.black;
  }
}

class LoanVault {
  final String vaultId;
  final LoanSchema schema;
  final String ownerAddress;
  final LoanVaultStatus state;
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

  LoanVaultHealthStatus get healthStatus {
    switch (this.state) {
      case LoanVaultStatus.active:
        {
          if (this.loanAmounts.length == 0) {
            return LoanVaultHealthStatus.active;
          }

          double minColRatio = double.tryParse(this.schema.minColRatio);
          double collateralRatio = double.tryParse(this.collateralRatio);
          double currentPercentage = collateralRatio / minColRatio;

          if (currentPercentage > 1.5) {
            return LoanVaultHealthStatus.healthy;
          } else {
            return LoanVaultHealthStatus.at_risk;
          }
        }
        break;

      case LoanVaultStatus.frozen:
        {
          return LoanVaultHealthStatus.halted;
        }

      case LoanVaultStatus.may_liquidate:
        {
          return LoanVaultHealthStatus.at_risk;
        }

      case LoanVaultStatus.in_liquidation:
        {
          return LoanVaultHealthStatus.liquidated;
        }

      case LoanVaultStatus.unknown:
        {
          return LoanVaultHealthStatus.unknown;
        }
    }

    return LoanVaultHealthStatus.unknown;
  }

  double get nextCollateralRatioDouble {
    var collaterals = collateralAmounts.map((e) => e.valueUSDNext);
    var loans = loanAmounts.map((e) => e.valueUSDNext);

    if (collaterals.length == 0 || loans.length == 0) {
      return -1;
    }

    return collaterals.fold(0, (previousValue, element) => 0 + element) / loans.fold(0, (previousValue, element) => 0 + element) * 100;
  }

  double get calcCollateralRatioDouble {
    var collaterals = collateralAmounts.map((e) => e.valueUSD);
    var loans = loanAmounts.map((e) => e.valueUSD);

    if (collaterals.length == 0 || loans.length == 0) {
      return -1;
    }

    return collaterals.fold(0, (previousValue, element) => 0 + element) / loans.fold(0, (previousValue, element) => 0 + element) * 100;
  }

  double get collateralRatioDouble {
    return double.tryParse(collateralRatio);
  }

  factory LoanVault.fromJson(Map<String, dynamic> json) {
    return LoanVault(
        vaultId: json['vaultId'],
        schema: LoanSchema.fromJson(json['loanScheme']),
        ownerAddress: json['ownerAddress'],
        state: LoanVaultStatus.values.firstWhere((e) => e.toShortString() == json['state'].toString().toLowerCase(), orElse: () => LoanVaultStatus.unknown),
        informativeRatio: json['informativeRatio'],
        collateralRatio: json['collateralRatio'],
        collateralValue: json['collateralValue'],
        loanValue: json['loanValue'],
        interestValue: json['interestValue'],
        collateralAmounts: json['collateralAmounts'] != null ? json['collateralAmounts'].map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data)).toList() : [],
        loanAmounts: json['loanAmounts'] != null ? json['loanAmounts'].map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data)).toList() : [],
        interestAmounts: json['interestAmounts'] != null ? json['interestAmounts'].map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data)).toList() : []);
  }
}
