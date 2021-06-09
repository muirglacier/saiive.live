class FromAccount {
  int amount;
  final String address;
  double get displayAmount => amount / 100000000;
  FromAccount({this.address, this.amount});
}
