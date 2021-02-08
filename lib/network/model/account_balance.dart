class AccountBalance {
  final String token;
  double balance;

  double get balanceDisplay => balance / 100000000;
  String get balanceDisplayRounded => (balance / 100000000).toStringAsFixed(8);

  AccountBalance({this.token, this.balance});
}
