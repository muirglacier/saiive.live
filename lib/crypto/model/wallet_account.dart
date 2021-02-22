import '../chain.dart';

class WalletAccount {
  int account;
  bool isChangeAddress = false;
  int id;
  ChainType chain;

  String name;

  int lastAccess;
  bool selected = false;
  String balance;
  String publicKey;

  WalletAccount({this.id, this.chain, this.account, this.isChangeAddress, this.name, this.lastAccess, this.selected = false, this.balance, this.publicKey});

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
        account: json['account'],
        isChangeAddress: json['isChangeAddress'] == "1",
        id: json['id'],
        chain: ChainType.values[json['chain']],
        name: json['name'],
        lastAccess: json['lastAccess'],
        selected: json['selected'],
        publicKey: json['publicKey'],
        balance: json['balance']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'isChangeAddress': isChangeAddress,
        'id': id,
        'chain': chain.index,
        'account': account,
        'lastAccess': lastAccess,
        'selected': selected,
        'publicKey': publicKey,
        'balance': balance
      };
}
