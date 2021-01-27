import 'dart:typed_data';
import 'dart:async';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

class WalletRestore {
  static Future<List<WalletAccount>> restore(ChainType chain, ChainNet network, String seed, String password, ApiService apiService,
      {List<int> existingAccounts}) async {
    int i = 0;
    int max = IWallet.MaxUnusedAccountScan;
    final api = apiService;

    final ret = List<WalletAccount>.empty(growable: true);

    final key = HEX.decode(seed);

    if (existingAccounts == null) {
      existingAccounts = [];
    }

    do {
      if (!existingAccounts.contains(i)) {
        final result = await _restore(i, key, api, chain, network);
        if (!result) {
          max--;
        } else {
          ret
            ..add(WalletAccount(
                name: ChainHelper.chainTypeString(chain) + (i + 1).toString(),
                id: i,
                account: i,
                chain: ChainType.DeFiChain));
          max = IWallet.MaxUnusedAccountScan;
        }
      }

      i++;
    } while (max > 0);

    return ret;
  }

  static Future<bool> _restore(int account, Uint8List key, ApiService api,
      ChainType chain, ChainNet net) async {
    int i = 0;
    int maxEmpty = IWallet.MaxUnusedIndexScan;
    var accountEmpty = true;
    var startDate = DateTime.now();
    do {
      var publicKeys = await HdWalletUtil.derivePublicKeys(key, account, false,
          IWallet.KeysPerQuery * i, chain, net, IWallet.KeysPerQuery);
      var path = HdWalletUtil.derivePaths(
          account, false, IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
      var transactions = await api.transactionService.getAddressesTransactions(
          ChainHelper.chainTypeString(chain), publicKeys);

      debugPrint(
          "found ${transactions.length} for path ${path.first} length ${IWallet.KeysPerQuery}");
      if (transactions.length == 0) {
        maxEmpty--;
      } else {
        return true;
      }
      i++;
    } while (maxEmpty > 0);

    var endDate = DateTime.now();

    var diff =
        endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("restore took ${diff / 1000} seconds");

    return !accountEmpty;
  }
}
