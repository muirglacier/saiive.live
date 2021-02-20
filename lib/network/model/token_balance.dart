class TokenBalance {
  final String hash;
  final String idToken;
  final int balance;
  final bool isPopularToken;

  String get balanceDisplayRounded => (balance / 100000000).toStringAsFixed(8);

  TokenBalance({
    this.hash,
    this.idToken,
    this.balance,
    this.isPopularToken,
  });
}
