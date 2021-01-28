import 'dart:async';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';

class HdWallet extends IHdWallet {
  int _nextFreeIndex;

  final String _password;
  final WalletAccount _account;
  final ChainType _chain;
  final ChainNet _network;
  final String _seed;
  final ApiService _apiService;

  HdWallet(this._password, this._account, this._chain, this._network,
      this._seed, this._apiService);

  @override
  Future<List<Account>> syncBalance() async {
    int empty = 0;
    int i = 0;
    _nextFreeIndex = 0;

    var startDate = DateTime.now();
    final key = HEX.decode(_seed);
    final apiService = _apiService;
    var balanceList = List<Account>();

    do {
      try {
        var keys = await HdWalletUtil.derivePublicKeys(
            key,
            _account.account,
            false,
            IWallet.KeysPerQuery * i,
            _chain,
            _network,
            IWallet.KeysPerQuery);
        var path = HdWalletUtil.derivePaths(_account.account, false,
            IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
        var pubKeyList = keys.map((item) => item).toList();
        var accountBalance = await apiService.accountService
            .getAccounts(ChainHelper.chainTypeString(_chain), pubKeyList);

        debugPrint(
            "found ${accountBalance.length} for path ${path.first} length ${IWallet.KeysPerQuery}");

        var anyBalanceFound = false;
        for (final balance in accountBalance) {
          anyBalanceFound = true;
          balanceList.addAll(balance.accounts);
        }

        if (anyBalanceFound) {
          _nextFreeIndex++;
        } else {
          empty++;
        }
      } catch (e) {
        debugPrint(e);
        continue;
      }

      if (empty >= IWallet.MaxUnusedIndexScan) {
        break;
      }

      i++;
      _nextFreeIndex++;
    } while (true);

    var endTxDate = DateTime.now();

    var diffTx =
        endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("tx sync took ${diffTx / 1000} seconds");

    startDate = DateTime.now();

    i = 1;

    var endDate = DateTime.now();

    var diff =
        endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("sync took ${diff / 1000} seconds");

    _nextFreeIndex++;
    return balanceList;
  }

  Future<List<Transaction>> syncTransactions() async {
    int empty = 0;
    int i = 0;
    _nextFreeIndex = 0;

    var startDate = DateTime.now();
    final key = HEX.decode(_seed);
    final apiService = _apiService;
    var txList = List<Transaction>();

    do {
      try {
        var keys = await HdWalletUtil.derivePublicKeys(
            key,
            _account.account,
            false,
            IWallet.KeysPerQuery * i,
            _chain,
            _network,
            IWallet.KeysPerQuery);
        var path = HdWalletUtil.derivePaths(_account.account, false,
            IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
        var pubKeyList = keys.map((item) => item).toList();
        var txs = await apiService.transactionService.getAddressesTransactions(
            ChainHelper.chainTypeString(_chain), pubKeyList);

        debugPrint(
            "found ${txs.length} transactions for path ${path.first} length ${IWallet.KeysPerQuery}");

        for (final tx in txs) {
          final keyIndex = keys.indexWhere((item) => item == tx.address);

          tx.index = keyIndex + (i * IWallet.KeysPerQuery);
          tx.account = _account.account;
        }
        txList.addAll(txs);
        var anyBalanceFound = txs.length > 0;

        if (anyBalanceFound) {
          _nextFreeIndex++;
        } else {
          empty++;
        }
      } catch (e) {
        debugPrint(e);
        continue;
      }

      if (empty >= IWallet.MaxUnusedIndexScan) {
        break;
      }

      i++;
      _nextFreeIndex++;
    } while (true);

    var endTxDate = DateTime.now();

    var diffTx =
        endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("tx sync took ${diffTx / 1000} seconds");

    startDate = DateTime.now();

    i = 1;

    var endDate = DateTime.now();

    var diff =
        endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("sync took ${diff / 1000} seconds");

    _nextFreeIndex++;
    return txList;
  }

  @override
  Future<String> nextFreePublicKey(ChainType chain) async {
    // final nextIndex = await _walletDatabase.getNextFreeIndex(_account.account);
    // final key = HEX.decode(_seed);

    // var publicKey = await HdWalletUtil.derivePublicKey(
    //     key, _account.account, false, nextIndex, chain, _network);

    // return publicKey;
    throw new Error();
  }
}
