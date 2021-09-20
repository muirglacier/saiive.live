class Coin {
  final String coin;
  final String idToken;
  final double fiat;
  final String currency;

  Coin({this.coin, this.idToken, this.fiat, this.currency});

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(coin: json['coin'], idToken: json['idToken'], fiat: double.parse(json['fiat'].toString()), currency: json['currency']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'coin': coin,
    'idToken': idToken,
    'fiat': fiat,
    'currency': currency
  };
}
