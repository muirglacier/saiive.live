import 'package:flutter/cupertino.dart';

import '../chain.dart';

enum WalletAccountType { HdAccount, PublicKey, PrivateKey }

class WalletAccount {
  final int account;
  final int id;
  final ChainType chain;

  String _uniqueId;

  String name;

  final int lastAccess;
  bool selected;

  WalletAccountType walletAccountType;

  get uniqueId => _uniqueId;

  setUniqueId(String uniqueId) {
    if (this._uniqueId == null || this._uniqueId.isEmpty) {
      this._uniqueId = uniqueId;
    }
  }

  static String getStringForWalletAccountType(WalletAccountType accountType) {
    switch (accountType) {
      case WalletAccountType.HdAccount:
        return "HDAccount";
      case WalletAccountType.PublicKey:
        return "PublicKey";
      case WalletAccountType.PrivateKey:
        return "PrivateKey";
    }
    return "";
  }

  WalletAccount(this._uniqueId,
      {@required this.id, @required this.chain, @required this.account, @required this.walletAccountType, @required this.name, this.lastAccess, this.selected = false});

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(json.containsKey("uniqueId") ? json["uniqueId"] : null,
        account: json['account'],
        id: json['id'],
        chain: ChainType.values[json['chain']],
        name: json['name'],
        lastAccess: json['lastAccess'],
        selected: json['selected'],
        walletAccountType: json.containsKey("walletAccountType") ? WalletAccountType.values[json['walletAccountType']] : WalletAccountType.HdAccount);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'chain': chain.index,
        'account': account,
        'lastAccess': lastAccess,
        'selected': selected,
        'walletAccountType': walletAccountType.index,
        'uniqueId': _uniqueId
      };
}
