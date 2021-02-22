import 'package:defichainwallet/network/model/account.dart';
import 'package:flutter/foundation.dart';

class KeyAccountWrapper {
  final String address;
  final List<Account> accounts;

  KeyAccountWrapper({@required this.address, @required this.accounts});

  factory KeyAccountWrapper.fromJson(Map<String, dynamic> json) {
    final accountList = (json['accounts'] as List);
    return KeyAccountWrapper(address: json['address'], accounts: accountList?.map((e) => Account.fromJson(e))?.toList());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'address': address, 'balance': accounts.map((e) => e.toJson()).toList()};
}
