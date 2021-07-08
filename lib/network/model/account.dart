import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/helper/constants.dart';

class Account {
  final String token;
  final String address;
  int balance;
  final String raw;
  String chain;
  String network;

  String accountId;

  Account({this.token, this.address, this.balance, this.raw, this.chain, this.network, this.accountId});

  String get key => token + "_" + address;
  double get balanceDisplay => balance / DefiChainConstants.COIN;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        token: json['token'],
        address: json['address'] ?? '',
        balance: double.parse(json['balance'].toString()).round(),
        raw: json['raw'] ?? '',
        chain: json['chain'],
        network: json['network'],
        accountId: json['accountId']);
  }

  FromAccount toFromAccount() {
    var fromAccount = FromAccount(address: address, amount: balance);
    return fromAccount;
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'token': token, 'address': address, 'balance': balance, 'raw': raw, 'chain': chain, 'network': network, 'accountId': accountId};
}
