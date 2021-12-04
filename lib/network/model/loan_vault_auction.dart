import 'package:flutter/material.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanVaultAuction {
  final String vaultId;
  final LoanSchema schema;
  final String ownerAddress;
  final LoanVaultStatus state;
  final int batchCount;
  final int liquidationHeight;
  final int liquidationPenalty;
  final List<LoanVaultAuctionBatch> batches;

  LoanVaultAuction(
      {this.vaultId,
      this.schema,
      this.ownerAddress,
      this.state,
      this.batchCount,
      this.liquidationHeight,
      this.liquidationPenalty,
      this.batches});

  factory LoanVaultAuction.fromJson(Map<String, dynamic> json) {
    return LoanVaultAuction(
        vaultId: json['vaultId'],
        schema: LoanSchema.fromJson(json['loanScheme']),
        ownerAddress: json['ownerAddress'],
        state: LoanVaultStatus.values.firstWhere(
            (e) => e.toShortString() == json['state'].toString().toLowerCase(),
            orElse: () => LoanVaultStatus.unknown),
        batchCount: json['batchCount'],
        liquidationHeight: json['liquidationHeight'],
        liquidationPenalty: json['liquidationPenalty'],
        batches: json['batches'] != null ? json['batches'].map<LoanVaultAuctionBatch>((data) => LoanVaultAuctionBatch.fromJson(data)).toList() : [],
    );
  }
}
