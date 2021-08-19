import 'package:flutter/cupertino.dart';

import '../chain.dart';

enum WalletAccountType { HdAccount, PublicKey, PrivateKey }
enum DerivationPathType { BIP32, BIP44, JellyfishBullshit, SingleKey }

class WalletAccount {
  final int account;
  final int id;
  final ChainType chain;

  String _uniqueId;

  String name;

  final int lastAccess;
  bool selected;

  WalletAccountType walletAccountType;
  DerivationPathType derivationPathType;

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
      {@required this.id,
      @required this.chain,
      @required this.account,
      @required this.walletAccountType,
      @required this.name,
      @required this.derivationPathType,
      this.lastAccess,
      this.selected = false});

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(json.containsKey("uniqueId") ? json["uniqueId"] : null,
        account: json['account'],
        id: json['id'],
        chain: ChainType.values[json['chain']],
        name: json['name'],
        lastAccess: json['lastAccess'],
        selected: json['selected'],
        walletAccountType: json.containsKey("walletAccountType") ? WalletAccountType.values[json['walletAccountType']] : WalletAccountType.HdAccount,
        derivationPathType: json.containsKey("derivationPathType") ? DerivationPathType.values[json['derivationPathType']] : DerivationPathType.BIP32);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'chain': chain.index,
        'account': account,
        'lastAccess': lastAccess,
        'selected': selected,
        'walletAccountType': walletAccountType.index,
        'derivationPathType': derivationPathType.index,
        'uniqueId': _uniqueId
      };
}
