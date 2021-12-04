import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanVaultAuctionHighestBid {
  final String owner;
  final LoanVaultAmount amount;

  LoanVaultAuctionHighestBid(
      {this.owner,
      this.amount,
      });

  factory LoanVaultAuctionHighestBid.fromJson(Map<String, dynamic> json) {
    return LoanVaultAuctionHighestBid(
        owner: json['owner'],
        amount: LoanVaultAmount.fromJson(json['amount'])
    );
  }
}
