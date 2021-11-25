import 'package:saiive.live/network/model/loan_vault_active_price.dart';
import 'package:saiive.live/network/model/token.dart';

class LoanCollateral {
  final String tokenId;
  final Token token;
  final String factor;
  final String priceFeedId;
  final int activateAfterBlock;
  final LoanVaultActivePrice activePrice;

  LoanCollateral(
      {this.tokenId,
      this.token,
      this.factor,
      this.priceFeedId,
      this.activateAfterBlock,
      this.activePrice});

  factory LoanCollateral.fromJson(Map<String, dynamic> json) {
    return LoanCollateral(
        tokenId: json['tokenId'],
        token: Token.fromJson(json['token']),
        factor: json['factor'],
        priceFeedId: json['priceFeedId'],
        activateAfterBlock: json['activateAfterBlock'],
        activePrice: json['activePrice'] != null ? LoanVaultActivePrice.fromJson(json['activePrice']) : null
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tokenId': tokenId,
        'token': token.toJson(),
        'factor': factor,
        'priceFeedId': priceFeedId,
        'activateAfterBlock': activateAfterBlock,
        'activePrice': activePrice != null ? activePrice.toJson() : null
      };
}
