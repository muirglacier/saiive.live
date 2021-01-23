class Token {
  final String symbol;
  final String symbolKey;
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
}
