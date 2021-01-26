class Account {
  final String token;
  final String address;
  final double balance;
  final String raw;

  Account({
    this.token,
    this.address,
    this.balance,
    this.raw,
  });

  String get key => token + "_" + address;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      token: json['token'],
      address: json['address'] ?? '',
      balance: double.parse(json['balance'].toString()),
      raw: json['raw'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'address': address,
        'balance': balance,
        'raw': raw
      };
}
