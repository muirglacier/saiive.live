import 'package:saiive.live/network/model/loan_token_token.dart';

class LoanToken {
  final String tokenId;
  final LoanTokenToken token;
  final String interest;
  final String fixedIntervalPriceId;

  LoanToken({this.tokenId, this.token, this.interest, this.fixedIntervalPriceId});

  factory LoanToken.fromJson(Map<String, dynamic> json) {
    return LoanToken(tokenId: json['tokenId'], token: LoanTokenToken.fromJson(json['token']), interest: json['interest'], fixedIntervalPriceId: json['fixedIntervalPriceId']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'tokenId': tokenId, 'token': token.toJson(), 'interest': interest, 'fixedIntervalPriceId': fixedIntervalPriceId};
}
