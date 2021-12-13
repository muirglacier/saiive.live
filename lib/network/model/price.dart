class PriceBlock {
  final String hash;
  final int height;
  final int medianTime;
  final int time;

  PriceBlock({this.hash, this.height, this.medianTime, this.time});

  factory PriceBlock.fromJson(Map<String, dynamic> json) {
    return PriceBlock(
      hash: json['hash'],
      height: json['height'],
      medianTime: json['medianTime'],
      time: json['time'],
    );
  }
}

class PriceValue {
  final double amount;

  PriceValue({this.amount});

  factory PriceValue.fromJson(Map<String, dynamic> json) {
    return PriceValue(amount: double.tryParse(json['amount']));
  }
}

class Price {
  final String id;
  final PriceBlock block;
  final PriceValue aggregated;
  final String currency;
  final String token;

  Price({this.id, this.block, this.aggregated, this.currency, this.token});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
        id: json['id'],
        block: PriceBlock.fromJson(json['price']['block']),
        aggregated: PriceValue.fromJson(json['price']['aggregated']),
        currency: json['price']['currency'],
        token: json['price']['token']);
  }
}
