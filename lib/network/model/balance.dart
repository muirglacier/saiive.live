import 'dart:convert';

balancesFromJson(dynamic input) {
  return json.decode(input.body).map<Balance>((data) => Balance.fromJson(data)).toList();
}

class Balance {
  final double confirmed;
  final double unconfirmed;
  final double balance;
  final String address;

  Balance({
    this.confirmed,
    this.unconfirmed,
    this.balance,
    this.address,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      confirmed: double.parse(json['confirmed'].toString()),
      unconfirmed: double.parse(json['unconfirmed'].toString()),
      balance: double.parse(json['balance'].toString()),
      address: json['address'],
    );
  }
}
