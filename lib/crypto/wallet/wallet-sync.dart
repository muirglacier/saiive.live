import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;

import 'package:defichainwallet/helper/logger/LogHelper.dart';

import '../chain.dart';

class WalletSync {
  static Future<List<tx.Transaction>> syncUTXO(
      ChainType chain,
      ChainNet network,
      String seed,
      String password,
      ApiService apiService,
      List<WalletAccount> wallets) async {
    var startDate = DateTime.now();
    var ret = List<tx.Transaction>.empty(growable: true);
    try {
      for (final wallet in wallets) {
        var hdWallet = HdWallet(password, wallet, chain, network,
            mnemonicToSeedHex(seed), apiService);
        var txs = await hdWallet.syncUnspentTransactions();
        ret.addAll(txs);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    }
    return ret;
  }

  static Future<List<tx.Transaction>> syncTransactions(
      ChainType chain,
      ChainNet network,
      String seed,
      String password,
      ApiService apiService,
      List<WalletAccount> wallets) async {
    var startDate = DateTime.now();
    var ret = List<tx.Transaction>.empty(growable: true);
    try {
      for (final wallet in wallets) {
        var hdWallet = HdWallet(password, wallet, chain, network,
            mnemonicToSeedHex(seed), apiService);
        var txs = await hdWallet.syncTransactions();
        ret.addAll(txs);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    }
    return ret;
  }

  static Future<List<Account>> syncBalance(
      ChainType chain,
      ChainNet network,
      String seed,
      String password,
      ApiService apiService,
      List<WalletAccount> wallets) async {
    var startDate = DateTime.now();
    var ret = List<Account>.empty(growable: true);
    try {
      for (final wallet in wallets) {
        var hdWallet = HdWallet(password, wallet, chain, network,
            mnemonicToSeedHex(seed), apiService);
        var balance = await hdWallet.syncBalance();
        ret.addAll(balance);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      LogHelper.instance.e("Error syncing wallet", e);
    }
    return ret;
  }
}
