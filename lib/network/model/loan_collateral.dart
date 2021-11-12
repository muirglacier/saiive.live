import 'package:saiive.live/network/model/token.dart';

class LoanCollateral {
  final String tokenId;
  final Token token;
  final String factor;
  final String priceFeedId;
  final int activateAfterBlock;

  LoanCollateral(
      {this.tokenId,
      this.token,
      this.factor,
      this.priceFeedId,
      this.activateAfterBlock});

  factory LoanCollateral.fromJson(Map<String, dynamic> json) {
    return LoanCollateral(
        tokenId: json['tokenId'],
        token: Token.fromJson(json['token']),
        factor: json['factor'],
        priceFeedId: json['priceFeedId'],
        activateAfterBlock: json['activateAfterBlock']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tokenId': tokenId,
        'token': token.toJson(),
        'factor': factor,
        'priceFeedId': priceFeedId,
        'activateAfterBlock': activateAfterBlock
      };
}
