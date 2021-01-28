import 'dart:core';

class Transaction {
  final String id;
  final String chain;
  final String network;
  final bool coinbase;
  final int mintIndex;
  final String spentTxId;
  final String mintTxId;
  final int mintHeight;
  final int spentHeight;
  final String address;
  final double value;
  final int confirmations;

  int index;
  int account;

  Transaction({
    this.id,
    this.chain,
    this.network,
    this.coinbase,
    this.mintIndex,
    this.spentTxId,
    this.mintTxId,
    this.mintHeight,
    this.spentHeight,
    this.address,
    this.value,
    this.confirmations,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      chain: json['chain'],
      network: json['network'],
      coinbase: json['coinbase'],
      mintIndex: json['mintIndex'],
      spentTxId: json['spentTxId'],
      mintTxId: json['mintTxId'],
      mintHeight: json['mintHeight'],
      spentHeight: json['spentHeight'],
      address: json['address'],
      value: double.parse(json['value'].toString()),
      confirmations: json['confirmations'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'chain': chain,
        'network': network,
        'coinbase': coinbase,
        'mintIndex': mintIndex,
        'spendTxId': spentTxId,
        'mintTxId': mintTxId,
        'mintHeight': mintHeight,
        'spentHeight': spentHeight,
        'address': address,
        'value': value,
        'confirmationsid': confirmations
      };
}
