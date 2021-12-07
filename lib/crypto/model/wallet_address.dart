import 'package:flutter/foundation.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';

import '../chain.dart';

class WalletAddress {
  final int account;
  final bool isChangeAddress;
  final int index;
  final ChainType chain;
  final ChainNet network;
  final AddressType addressType;

  final String accountId;

  String name;
  DateTime createdAt;
  final String publicKey;

  String get uniqueId =>
      accountId + "_" + chain.index.toString() + "_" + account.toString() + "_" + (isChangeAddress ? "1" : "0") + "_" + index.toString() + "_" + addressType.index.toString();

  String path(WalletAccount account) => HdWalletUtil.derivePath(account.account, isChangeAddress, index, account.derivationPathType);

  WalletAddress(
      {@required this.accountId,
      @required this.index,
      @required this.chain,
      @required this.account,
      @required this.isChangeAddress,
      @required this.publicKey,
      @required this.network,
      @required this.addressType,
      this.name,
      this.createdAt});

  factory WalletAddress.fromJson(Map<String, dynamic> json) {
    return WalletAddress(
        account: json['account'],
        isChangeAddress: json['isChangeAddress'],
        index: json['index'],
        chain: ChainType.values[json['chain']],
        network: ChainNet.values[json['network']],
        publicKey: json['publicKey'],
        accountId: json.containsKey("accountId") ? json["accountId"] : "00000000-0000-0000-0000-000000000000",
        addressType: json.containsKey("addressType") ? AddressType.values[json['addressType']] : AddressType.P2SHSegwit,
        name: json.containsKey("name") ? json["name"] : "",
        createdAt: json.containsKey("createdAt") ? DateTime.parse(json["createdAt"]) : null);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'account': account,
        'isChangeAddress': isChangeAddress,
        'index': index,
        'chain': chain.index,
        'publicKey': publicKey,
        'network': network.index,
        'addressType': addressType == null ? AddressType.P2SHSegwit.index : addressType.index,
        'accountId': accountId != null ? accountId : "00000000-0000-0000-0000-000000000000",
        'name': name,
        if (createdAt != null) 'createdAt': createdAt.toIso8601String()
      };
}
