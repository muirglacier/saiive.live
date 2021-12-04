import 'package:saiive.live/network/model/loan_vault_auction_batch_highest_bid.dart';
import 'package:saiive.live/network/model/loan_vault_collateral_amount.dart';

class LoanVaultAuctionBatch {
  final int index;
  final List<LoanVaultAmount> collaterals;
  final LoanVaultAmount loan;
  final LoanVaultAuctionHighestBid highestBid;

  LoanVaultAuctionBatch({this.index, this.collaterals, this.loan, this.highestBid});

  double get collateralValueUSD {
    return collaterals.fold(0, (previous, e) {
      return previous + e.valueUSD;
    });
  }

  factory LoanVaultAuctionBatch.fromJson(Map<String, dynamic> json) {
    return LoanVaultAuctionBatch(
        index: json['index'],
        collaterals: json['collaterals'] != null ? json['collaterals'].map<LoanVaultAmount>((data) => LoanVaultAmount.fromJson(data)).toList() : [],
        loan: LoanVaultAmount.fromJson(json['loan']),
        highestBid: json['highestBid'] != null ? LoanVaultAuctionHighestBid.fromJson(json['highestBid']) : null);
  }
}
