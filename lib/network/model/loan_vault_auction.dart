import 'dart:math';

import 'package:intl/intl.dart';
import 'package:saiive.live/helper/constants.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_vault.dart';
import 'package:saiive.live/network/model/loan_vault_auction_batch.dart';

class LoanVaultAuction {
  final String vaultId;
  final LoanSchema schema;
  final String ownerAddress;
  final LoanVaultStatus state;
  final int batchCount;
  final int liquidationHeight;
  final int liquidationPenalty;
  final List<LoanVaultAuctionBatch> batches;

  LoanVaultAuction({this.vaultId, this.schema, this.ownerAddress, this.state, this.batchCount, this.liquidationHeight, this.liquidationPenalty, this.batches});

  String calculateEndDate(int blockCount) {
    if (blockCount > liquidationHeight) {
      return null;
    }

    var now = DateTime.now();
    var time = (calculateRemainingBlocks(blockCount) * DefiChainConstants.BLOCK_TIME_S).floor();
    now = now.add(Duration(seconds: time));
    final f = new DateFormat('dd.MM.yyyy HH:mm');

    return f.format(now);
  }

  int calculateRemainingBlocks(int blockCount) {
    return max(liquidationHeight - blockCount, 0);
  }

  factory LoanVaultAuction.fromJson(Map<String, dynamic> json) {
    return LoanVaultAuction(
      vaultId: json['vaultId'],
      schema: LoanSchema.fromJson(json['loanScheme']),
      ownerAddress: json['ownerAddress'],
      state: LoanVaultStatus.values.firstWhere((e) => e.toShortString() == json['state'].toString().toLowerCase(), orElse: () => LoanVaultStatus.unknown),
      batchCount: json['batchCount'],
      liquidationHeight: json['liquidationHeight'],
      liquidationPenalty: json['liquidationPenalty'],
      batches: json['batches'] != null ? json['batches'].map<LoanVaultAuctionBatch>((data) => LoanVaultAuctionBatch.fromJson(data)).toList() : [],
    );
  }
}
