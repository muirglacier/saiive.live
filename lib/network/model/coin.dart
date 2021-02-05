class Coin {
  final String coin;
  final double fiat;
  final String currency;

  Coin({
    this.coin,
    this.fiat,
    this.currency
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      coin: json['coint'],
      fiat: double.parse(json['fiat'].toString()),
      currency: json['currency']
    );
  }
}
