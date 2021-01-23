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
      spentTxId: json['spendTxId'],
      mintTxId: json['mintTxId'],
      mintHeight: json['mintHeight'],
      spentHeight: json['spentHeight'],
      address: json['address'],
      value: json['value'],
      confirmations: json['confirmations'],
    );
  }
}
