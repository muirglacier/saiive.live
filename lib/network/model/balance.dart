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
      confirmed: json['confirmed'],
      unconfirmed: json['unconfirmed'],
      balance: json['balance'],
      address: json['address'],
    );
  }
}
