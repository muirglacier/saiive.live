import 'dart:typed_data';
import 'dart:async';
import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:hex/hex.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:tuple/tuple.dart';

class WalletRestore {
  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> restore(ChainType chain, ChainNet network, String seed, String password, ApiService apiService, {List<int> existingAccounts}) async {
    assert(chain != null);
    assert(network != null);
    assert(seed != null);
    assert(password != null);
    assert(apiService != null);

    int i = 0;
    int max = IWallet.MaxUnusedAccountScan;
    final api = apiService;

    final ret = List<WalletAccount>.empty(growable: true);
    final walletAddresses = List<WalletAddress>.empty(growable: true);

    final key = HEX.decode(mnemonicToSeedHex(seed));
    if (existingAccounts == null) {
      existingAccounts = [];
    }

    do {
      if (!existingAccounts.contains(i)) {
        final result = await _restore(i, key, api, chain, network);

        if (result.isEmpty) {
          max--;
        } else {
          walletAddresses.addAll(result);
          ret..add(WalletAccount(name: ChainHelper.chainTypeString(chain) + (i + 1).toString(), id: i, account: i, chain: ChainType.DeFiChain));
          max = IWallet.MaxUnusedAccountScan;
        }
      }

      i++;
    } while (max > 0);

    return Tuple2(ret, walletAddresses);
  }

  static Future<List<WalletAddress>> _restore(int account, Uint8List key, ApiService api, ChainType chain, ChainNet net) async {
    int i = 0;
    int maxEmpty = IWallet.MaxUnusedIndexScan;
    var startDate = DateTime.now();
    var addresses = List<WalletAddress>.empty(growable: true);

    do {
      var publicKeys = await HdWalletUtil.derivePublicKeysWithChange(key, account, IWallet.KeysPerQuery * i, chain, net, IWallet.KeysPerQuery);
      var path = HdWalletUtil.derivePathsWithChange(account, IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);

      var transactions = await api.transactionService.getAddressesTransactions(ChainHelper.chainTypeString(chain), publicKeys);
      LogHelper.instance.d("found ${transactions.length} for path ${path.first} length ${IWallet.KeysPerQuery}");

      for (final tx in transactions) {
        final keyIndex = publicKeys.indexWhere((item) => item == tx.address);
        var pathString = path[keyIndex];

        final walletAddress = WalletAddress(
            account: account,
            index: HdWalletUtil.getIndexFromPath(pathString),
            isChangeAddress: HdWalletUtil.isPathChangeAddress(pathString),
            chain: chain,
            network: net,
            publicKey: publicKeys[keyIndex]);

        addresses.add(walletAddress);
      }

      if (transactions.length == 0) {
        maxEmpty--;
      } else {
        return addresses;
      }
      i++;
    } while (maxEmpty > 0);

    var endDate = DateTime.now();

    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("restore took ${diff / 1000} seconds");

    return addresses;
  }
}
