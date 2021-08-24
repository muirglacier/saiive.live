import 'package:flutter/cupertino.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';

import '../chain.dart';

enum WalletAccountType { HdAccount, PublicKey, PrivateKey }
enum PathDerivationType { FullNodeWallet, BIP32, BIP44, JellyfishBullshit, SingleKey }

String pathDerivationTypeString(PathDerivationType pathDerivationType) {
  switch (pathDerivationType) {
    case PathDerivationType.FullNodeWallet:
      return "FullNodeWallet";
    case PathDerivationType.BIP32:
      return "BIP32";
    case PathDerivationType.BIP44:
      return "BIP44";
    case PathDerivationType.JellyfishBullshit:
      return "JellyfishBS";
    case PathDerivationType.SingleKey:
      return "SingleKey";
    default:
      return "NOTFOUND!";
  }
}

AddressType getDefaultAddressTypeForPathDerivation(PathDerivationType pathDerivationType) {
  switch (pathDerivationType) {
    case PathDerivationType.JellyfishBullshit:
      return AddressType.Bech32;
    default:
      return AddressType.P2SHSegwit;
  }
}

class WalletAccount {
  final int account;
  final int id;
  final ChainType chain;

  String _uniqueId;

  String name;

  final int lastAccess;
  bool selected;

  WalletAccountType walletAccountType;
  PathDerivationType derivationPathType;
  AddressType defaultAddressType = AddressType.P2SHSegwit;

  get uniqueId => _uniqueId;

  setUniqueId(String uniqueId) {
    if (this._uniqueId == null || this._uniqueId.isEmpty) {
      this._uniqueId = uniqueId;
    }
  }

  static String getStringForWalletAccountType(WalletAccountType accountType) {
    switch (accountType) {
      case WalletAccountType.HdAccount:
        return "HD";
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
      this.defaultAddressType,
      this.selected = false}) {
    if (this.defaultAddressType == null) {
      this.defaultAddressType = getDefaultAddressTypeForPathDerivation(this.derivationPathType);
    }
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(json.containsKey("uniqueId") ? json["uniqueId"] : null,
        account: json['account'],
        id: json['id'],
        chain: ChainType.values[json['chain']],
        name: json['name'],
        lastAccess: json['lastAccess'],
        selected: json['selected'],
        walletAccountType: json.containsKey("walletAccountType") ? WalletAccountType.values[json['walletAccountType']] : WalletAccountType.HdAccount,
        derivationPathType: json.containsKey("pathDerivationType") ? PathDerivationType.values[json['pathDerivationType']] : PathDerivationType.FullNodeWallet,
        defaultAddressType: json.containsKey("defaultAddressType") ? AddressType.values[json['defaultAddressType']] : AddressType.P2SHSegwit);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'chain': chain.index,
        'account': account,
        'lastAccess': lastAccess,
        'selected': selected,
        'walletAccountType': walletAccountType.index,
        'pathDerivationType': derivationPathType.index,
        'uniqueId': _uniqueId,
        "defaultAddressType": defaultAddressType.index
      };
}
