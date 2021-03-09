import 'package:defichainwallet/helper/constants.dart';

class AccountHistory {
  final String owner;
  final int blockHeight;
  final String blockHash;
  final int blockTime;
  final String type;
  final String poolID;
  final int txn;
  final String txid;
  final List<dynamic> amounts;

  AccountHistory({
    this.owner,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
    this.type,
    this.poolID,
    this.txn,
    this.txid,
    this.amounts
  });

  int getBalance(String token)
  {
    double amount = 0;

    this.amounts.forEach((dynamic element) {
      String idToken = element.toString().split('@')[1];
      double reward = double.tryParse(element.toString().split('@')[0]);

      if (idToken == token) {
        amount += reward;
      }
    });

    return (amount * DefiChainConstants.COIN).round();
  }

  factory AccountHistory.fromJson(Map<String, dynamic> json) {
    return AccountHistory(
        owner: json['owner'],
        blockHeight: json['blockHeight'] ?? '',
        blockHash: json['blockHash'],
        blockTime: json['blockTime'],
        type: json['type'],
        poolID: json['poolID'],
        txn: json['txn'],
        txid: json['txId'],
        amounts: json['amounts']
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{};
}
