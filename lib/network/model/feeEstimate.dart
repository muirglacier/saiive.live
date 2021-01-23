class FeeEstimate {
  final int blocks;
  final double feeRate;

  FeeEstimate({
    this.blocks,
    this.feeRate,
  });

  factory FeeEstimate.fromJson(Map<String, dynamic> json) {
    return FeeEstimate(
      blocks: json['blocks'],
      feeRate: json['feeRate'],
    );
  }
}
