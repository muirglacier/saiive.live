class YieldFarming {
  double apr;
  String name;
  String pair;
  String logo;
  List<dynamic> poolRewards;
  String pairLink;
  double apy;
  String idTokenA;
  String idTokenB;
  double reserveA;
  double reserveB;
  double volumeA;
  double volumeB;
  String tokenSymbolA;
  String tokenSymbolB;
  double priceA;
  double priceB;

  YieldFarming({
    this.apr,
    this.name,
    this.pair,
    this.logo,
    this.poolRewards,
    this.pairLink,
    this.apy,
    this.idTokenA,
    this.idTokenB,
    this.reserveA,
    this.reserveB,
    this.volumeA,
    this.volumeB,
    this.tokenSymbolA,
    this.tokenSymbolB,
    this.priceA,
    this.priceB,
  });

  factory YieldFarming.fromJson(Map<String, dynamic> json) {
    return YieldFarming(
      apr: double.parse(json['apr'].toString()),
      name: json['name'],
      pair: json['pair'],
      logo: json['logo'],
      poolRewards: json['poolRewards'],
      pairLink: json['pairLink'],
      apy: double.parse(json['apy'].toString()),
      idTokenA: json['idTokenA'],
      idTokenB: json['idTokenB'],
      reserveA: double.parse(json['reserveA'].toString()),
      reserveB: double.parse(json['reserveB'].toString()),
      volumeA: double.parse(json['volumeA'].toString()),
      volumeB: double.parse(json['volumeB'].toString()),
      tokenSymbolA: json['tokenSymbolA'],
      tokenSymbolB: json['tokenSymbolB'],
      priceA: double.parse(json['priceA'].toString()),
      priceB: double.parse(json['priceB'].toString()),
    );
  }
}
