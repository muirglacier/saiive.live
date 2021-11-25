class LoanVaultPriceBlock {
  final String hash;
  final int height;
  final int medianTime;
  final int time;

  LoanVaultPriceBlock({
    this.hash,
    this.height,
    this.medianTime,
    this.time,
  });

  factory LoanVaultPriceBlock.fromJson(Map<String, dynamic> json) {
    return LoanVaultPriceBlock(
      hash: json['hash'],
      height: json['height'],
      medianTime: json['medianTime'],
      time: json['time'],
    );
  }
}
