import 'package:saiive.live/network/model/account.dart';

class DefichainWalletHelper {
  static Future<Account> getHighestAmountAddressForSymbol(List<Account> list, int amount) {
    list.sort((a, b) => b.balance.compareTo(a.balance));

    return Future.value(list.first);
  }
}
