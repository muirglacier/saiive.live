import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/service_locator.dart';

class BalanceHelper {
  Future<List<AccountBalance>> getDisplayAccountBalance() async {
    var accountBalance = await sl.get<IWalletDatabase>().getTotalBalances();
    if (accountBalance.isNotEmpty) {
      var dollarDFI = accountBalance.firstWhere(
          (element) => element.token == DeFiConstants.DefiTokenSymbol,
          orElse:() => AccountBalance(balance: 0, token: DeFiConstants.DefiTokenSymbol));
      var dfi = accountBalance.firstWhere(
          (element) => element.token == DeFiConstants.DefiAccountSymbol,
          orElse: () => AccountBalance(balance: 0, token: DeFiConstants.DefiAccountSymbol));

      if (dfi != null && dollarDFI != null) {
        accountBalance.remove(dollarDFI);

        dfi.balance += dollarDFI.balance;
      }

      accountBalance.sort((a, b) {
        if (a.token == 'DFI') {
          return -1;
        }
        if (b.token == 'DFI') {
          return 1;
        }

        return a.token.compareTo(b.token);
      });
    }

    return accountBalance;
  }
}
