import 'package:saiive.live/network/model/loan_vault_active_price.dart';
import 'package:saiive.live/network/model/token.dart';

class LoanToken {
  final String tokenId;
  final Token token;
  final String interest;
  final String fixedIntervalPriceId;
  final LoanVaultActivePrice activePrice;

  LoanToken({this.tokenId, this.token, this.interest, this.fixedIntervalPriceId, this.activePrice});

  factory LoanToken.fromJson(Map<String, dynamic> json) {
    return LoanToken(
        tokenId: json['tokenId'],
        token: Token.fromJson(json['token']),
        interest: json['interest'],
        fixedIntervalPriceId: json['fixedIntervalPriceId'],
        activePrice: json['activePrice'] != null ? LoanVaultActivePrice.fromJson(json['activePrice']) : null
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tokenId': tokenId,
        'token': token.toJson(),
        'interest': interest,
        'fixedIntervalPriceId': fixedIntervalPriceId,
        'activePrice': activePrice != null ? activePrice.toJson(): ''
      };
}
