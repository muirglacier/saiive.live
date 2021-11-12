class Token {
  final String symbol;
  final String symbolKey;
  final int id;
  final String name;
  final int decimal;
  final bool mintable;
  final bool tradeable;
  final bool isDAT;
  final bool isLPS;
  final bool finalized;
  final double minted;
  final String creationTx;
  final int creationHeight;
  final String destructionTx;
  final int destructionHeight;
  final String collateralAddress;

  Token({
    this.symbol,
    this.symbolKey,
    this.id,
    this.name,
    this.decimal,
    this.mintable,
    this.tradeable,
    this.isDAT,
    this.isLPS,
    this.finalized,
    this.minted,
    this.creationTx,
    this.creationHeight,
    this.destructionTx,
    this.destructionHeight,
    this.collateralAddress,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      symbol: json['symbol'],
      symbolKey: json['symbolKey'],
      id: json['id'],
      name: json['name'],
      decimal: json['decimal'],
      mintable: json['mintable'],
      tradeable: json['tradeable'],
      isDAT: json['isDAT'],
      isLPS: json['isLPS'],
      finalized: json['finalized'],
      minted: double.parse(json['minted'].toString()),
      creationTx: json['creationTx'],
      creationHeight: json['creationHeight'],
      destructionTx: json['destructionTx'],
      destructionHeight: json['destructionHeight'],
      collateralAddress: json['collateralAddress'],
    );
  }

  factory Token.fromJsonEntry(Map<String, dynamic> json) {
    return Token(
      symbol: json['symbol'],
      symbolKey: json['symbolKey'],
      id: json["id"],
      name: json['name'],
      decimal: json['decimal'],
      mintable: json['mintable'],
      tradeable: json['tradeable'],
      isDAT: json['isDAT'],
      isLPS: json['isLPS'],
      finalized: json['finalized'],
      minted: json['minted'],
      creationTx: json['creationTx'],
      creationHeight: json['creationHeight'],
      destructionTx: json['destructionTx'],
      destructionHeight: json['destructionHeight'],
      collateralAddress: json['collateralAddress'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id
  };
}
