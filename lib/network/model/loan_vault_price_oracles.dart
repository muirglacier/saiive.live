class LoanVaultPriceOracles {
  final int active;
  final int total;

  LoanVaultPriceOracles({this.active, this.total});

  factory LoanVaultPriceOracles.fromJson(Map<String, dynamic> json) {
    return LoanVaultPriceOracles(
      active: json['active'],
      total: json['total'],
    );
  }
}
