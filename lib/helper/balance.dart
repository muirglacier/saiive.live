import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain_wallet.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/service_locator.dart';

class BalanceHelper {
  Future<AccountBalance> getAccountBalance(String token, ChainType chain) async {
    if (chain == ChainType.DeFiChain) {
      var walletService = sl.get<DeFiChainWallet>();

      if (DeFiConstants.isDfiToken(token)) {
        var accountBalance = await walletService.getDatabase().getAccountBalance(DeFiConstants.DefiAccountSymbol);
        var tokenBalance = await walletService.getDatabase().getAccountBalance(DeFiConstants.DefiTokenSymbol);

        accountBalance.balance += tokenBalance.balance;

        return accountBalance;
      }

      var accountBalance = await walletService.getDatabase().getAccountBalance(token);

      return accountBalance;
    } else if (chain == ChainType.Bitcoin) {
      var btcWalletService = sl.get<BitcoinWallet>();

      return btcWalletService.getDatabase().getAccountBalance(null);
    }

    return null;
  }

  Future<List<AccountBalance>> getDisplayAccountBalance({bool onlyDfi = false}) async {
    var walletService = sl.get<DeFiChainWallet>();
    var accountBalance = await walletService.getDatabase().getTotalBalances();
    var tokens = await sl.get<ITokenService>().getTokens(DeFiConstants.DefiAccountSymbol);

    var btcWalletService = sl.get<BitcoinWallet>();
    var btcAccountBalance = await btcWalletService.getDatabase().getTotalBalances();

    if (accountBalance.isNotEmpty) {
      var dollarDFI = accountBalance.firstWhere((element) => element.token == DeFiConstants.DefiTokenSymbol,
          orElse: () => AccountBalance(balance: 0, token: DeFiConstants.DefiTokenSymbol, chain: ChainType.DeFiChain));
      var dfi = accountBalance.firstWhere((element) => element.token == DeFiConstants.DefiAccountSymbol,
          orElse: () => AccountBalance(balance: 0, token: DeFiConstants.DefiAccountSymbol, chain: ChainType.DeFiChain));

      var dfiBalance =
          new MixedAccountBalance(token: "DFI", balance: dollarDFI.balance + dfi.balance, utxoBalance: dollarDFI.balance, tokenBalance: dfi.balance, chain: ChainType.DeFiChain);

      if (dfi != null) {
        accountBalance.remove(dfi);
      }

      if (dollarDFI != null) {
        accountBalance.remove(dollarDFI);
      }

      accountBalance.forEach((element) {
        var token = tokens.firstWhere((tokenElement) => tokenElement.symbol == element.token, orElse: () => null);

        if (token != null) {
          element.isDAT = token.isDAT;
          element.isLPS = token.isLPS;
        }
      });

      accountBalance.sort((a, b) {
        if (a.isLPS && b.isDAT) {
          return 1;
        }

        if (b.isLPS && a.isDAT) {
          return -1;
        }

        return 0;
      });

      accountBalance.insert(0, dfiBalance);
      if (!onlyDfi) {
        accountBalance.insert(1, btcAccountBalance.first);
      }
    }

    return accountBalance;
  }
}
