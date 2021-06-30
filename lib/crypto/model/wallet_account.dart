import 'package:flutter/cupertino.dart';

import '../chain.dart';

enum WalletAccountType { HdAccount, PublicKey, PrivateKey }

class WalletAccount {
  final int account;
  final int id;
  final ChainType chain;

  final String uniqueId;

  final String name;

  final int lastAccess;
  final bool selected;

  final WalletAccountType walletAccountType;

  WalletAccount(
      {@required this.uniqueId,
      @required this.id,
      @required this.chain,
      @required this.account,
      @required this.walletAccountType,
      @required this.name,
      this.lastAccess,
      this.selected = false});

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
        account: json['account'],
        id: json['id'],
        chain: ChainType.values[json['chain']],
        name: json['name'],
        lastAccess: json['lastAccess'],
        selected: json['selected'],
        walletAccountType: json.containsKey("walletAccountType") ? WalletAccountType.values[json['walletAccountType']] : WalletAccountType.HdAccount,
        uniqueId: json.containsKey("uniqueId") ? json["uniqueId"] : "00000000-0000-0000-0000-000000000000");
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'chain': chain.index,
        'account': account,
        'lastAccess': lastAccess,
        'selected': selected,
        'walletAccountType': walletAccountType.index,
        'uniqueId': uniqueId
      };
}
