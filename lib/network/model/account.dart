class Account {
  final String token;
  final String address;
  final int balance;
  final String raw;
  int account;
  bool isChangeAddress;
  int index;
  String chain;
  String network;

  Account(
      {this.token,
      this.address,
      this.balance,
      this.raw,
      this.account,
      this.isChangeAddress,
      this.index,
      this.chain,
      this.network});

  String get key => token + "_" + address;
  double get balanceDisplay => balance / 100000000;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        token: json['token'],
        address: json['address'] ?? '',
        balance: int.parse(json['balance'].toString()),
        raw: json['raw'] ?? '',
        index: json['index'],
        account: json['account'],
        isChangeAddress: json['isChangeAddress'],
        chain: json['chain'],
        network: json['network']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'address': address,
        'balance': balance,
        'raw': raw,
        'index': index,
        'account': account,
        'isChangeAddress': isChangeAddress,
        'chain': chain,
        'network': network
      };
}
