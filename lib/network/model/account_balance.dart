class AccountBalance {
  final String token;
  double balance;

  double get balanceDisplay => balance / 100000000;

  AccountBalance({this.token, this.balance});
}
