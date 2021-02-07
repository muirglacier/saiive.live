class PoolShare {
  final String key;
  final String poolID;
  final String owner;
  final double amount;
  final double percent;
  final double totalLiquidity;

  PoolShare({
    this.key,
    this.poolID,
    this.owner,
    this.amount,
    this.percent,
    this.totalLiquidity,
  });

  factory PoolShare.fromJson(Map<String, dynamic> json) {
    return PoolShare(
      key: json['key'],
      poolID: json['poolID'],
      owner: json['owner'],
      amount: double.tryParse(json['amount'].toString()),
      percent: double.tryParse(json['percent'].toString()),
      totalLiquidity: double.tryParse(json['totalLiquidity'].toString()),
    );
  }
}
