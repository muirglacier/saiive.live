import '../chain.dart';

class WalletAddress {
  int account;
  bool isChangeAddress = false;
  int index;
  ChainType chain;
  ChainNet network;

  String name;

  String publicKey;

  String get uniqueId =>
      account.toString() +
      "_" +
      (isChangeAddress ? "1" : "0") +
      "_" +
      index.toString();

  WalletAddress(
      {this.index,
      this.chain,
      this.account,
      this.isChangeAddress,
      this.name,
      this.publicKey,
      this.network});

  factory WalletAddress.fromJson(Map<String, dynamic> json) {
    return WalletAddress(
      account: json['account'],
      isChangeAddress: json['isChangeAddress'],
      index: json['index'],
      chain: ChainType.values[json['chain']],
      network: ChainNet.values[json['chain']],
      name: json['name'],
      publicKey: json['publicKey'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'account': account,
        'isChangeAddress': isChangeAddress,
        'index': index,
        'chain': chain.index,
        'publicKey': publicKey,
        'network': network.index,
      };
}
