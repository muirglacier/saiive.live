class PoolPair {
  final String id;
  final String symbol;
  final String name;
  final bool status;
  final String idTokenA;
  final String idTokenB;
  final double reserveA;
  final double reserveB;
  final double commission;
  final double totalLiquidity;
  final double reserveADivReserveB;
  final double reserveBDivReserveA;
  final bool tradeEnabled;
  final String ownerAddress;
  final double blockCommissionA;
  final double blockCommissionB;
  final double rewardPct;
  final List<dynamic> customRewards;
  final String creationTx;
  final int creationHeight;

  PoolPair({
    this.id,
    this.symbol,
    this.name,
    this.status,
    this.idTokenA,
    this.idTokenB,
    this.reserveA,
    this.reserveB,
    this.commission,
    this.totalLiquidity,
    this.reserveADivReserveB,
    this.reserveBDivReserveA,
    this.tradeEnabled,
    this.ownerAddress,
    this.blockCommissionA,
    this.blockCommissionB,
    this.rewardPct,
    this.customRewards,
    this.creationTx,
    this.creationHeight,
  });

  factory PoolPair.fromJson(Map<String, dynamic> json) {
    return PoolPair(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      status: json['status'],
      idTokenA: json['idTokenA'],
      idTokenB: json['idTokenB'],
      reserveA: double.tryParse(json['reserveA'].toString()),
      reserveB: double.tryParse(json['reserveB'].toString()),
      commission: double.tryParse(json['commission'].toString()),
      totalLiquidity: double.tryParse(json['totalLiquidity'].toString()),
      reserveADivReserveB: double.tryParse(json['reserveADivReserveB'].toString()),
      reserveBDivReserveA: double.tryParse(json['reserveBDivReserveA'].toString()),
      tradeEnabled: json['tradeEnabled'],
      ownerAddress: json['ownerAddress'],
      blockCommissionA: double.tryParse(json['blockCommissionA'].toString()),
      blockCommissionB: double.tryParse(json['blockCommissionB'].toString()),
      rewardPct: double.parse(json['rewardPct'].toString()),
      customRewards: json['customRewards'],
      creationTx: json['creationTx'],
      creationHeight: json['creationHeight'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'symbol': symbol,
        'name': name,
        'status': status,
        'idTokenA': idTokenA,
        'idTokenB': idTokenB,
        'reserveA': reserveA,
        'reserveB': reserveB,
        'commission': commission,
        'totalLiquidity': totalLiquidity,
        'reserveADivReserveB': reserveADivReserveB,
        'reserveBDivReserveA': reserveBDivReserveA,
        'tradeEnabled': tradeEnabled,
        'ownerAddress': ownerAddress,
        'blockCommissionA': blockCommissionA,
        'blockCommissionB': blockCommissionB,
        'rewardPct': rewardPct,
        'customRewards': customRewards,
        'creationTx': creationTx,
        'creationHeight': creationHeight,
      };
}
