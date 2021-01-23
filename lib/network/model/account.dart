
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

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      token: json['token'],
      address: json['address'] ?? '',
      balance: json['balance'],
      raw: json['raw'] ?? '',
    );
  }
}
