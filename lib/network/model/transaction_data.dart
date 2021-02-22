import 'dart:core';

import 'package:defichainwallet/helper/constants.dart';
import 'package:defichainwallet/network/model/transaction.dart';

class TransactionDetail {
  final List<Transaction> inputs;
  final List<Transaction> outputs;

  TransactionDetail({this.inputs, this.outputs});

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    final inputs = (json['inputs'] as List);
    final outputs = (json['outputs'] as List);

    final txInputs = inputs?.map((e) => Transaction.fromJson(e))?.toList();
    final txOutputs = outputs?.map((e) => Transaction.fromJson(e))?.toList();
    return TransactionDetail(inputs: txInputs, outputs: txOutputs);
  }
}

class TransactionData {
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
  final int value;
  final int confirmations;
  final TransactionDetail details;

  int get valueRaw => (value).round();
  String get uniqueId => mintTxId + "_" + mintIndex.toString();

  int index;
  int account;
  bool isChangeAddress;
  String txId;

  int get correctValue => (spentHeight <= 0) ? value : (value * -1);
  String get correctValueRounded => (correctValue / DefiChainConstants.COIN).toStringAsFixed(8);

  TransactionData(
      {this.id,
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
      this.index,
      this.account,
      this.isChangeAddress,
      this.details});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
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
        value: int.parse(json['value'].toString()),
        confirmations: json['confirmations'],
        index: json['index'],
        account: json['account'],
        isChangeAddress: json['isChangeAddress'],
        details: TransactionDetail.fromJson(json["details"]));
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
        'confirmationsid': confirmations,
        'index': index,
        'account': account,
        'isChangeAddress': isChangeAddress
      };
}
