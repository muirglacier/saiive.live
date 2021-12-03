import 'dart:typed_data';
import 'dart:async';
import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/wallet.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:hex/hex.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class WalletRestore {
  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> restore(ChainType chain, ChainNet network, String seed, String password, ApiService apiService,
      {List<int> existingAccounts}) async {
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
        var all = await _restoreAll(i, key, api, chain, network);

        final result = List<WalletAddress>.from(all.item2);

        if (result.isEmpty) {
          max--;
        } else {
          walletAddresses.addAll(result);
          ret.addAll(all.item1);
          max = IWallet.MaxUnusedAccountScan;
        }
      }

      i++;
    } while (max > 0);

    return Tuple2(ret, walletAddresses);
  }

  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> _restoreAll(int account, List<int> key, ApiService api, ChainType chain, ChainNet network) async {
    var walletAccounts = List<WalletAccount>.empty(growable: true);
    var walletAddresses = List<WalletAddress>.empty(growable: true);

    void checkIfExistingAndAddToList(Tuple2<WalletAccount, List<WalletAddress>> data) {
      if (data.item2.isNotEmpty) {
        walletAccounts.add(data.item1);
        walletAddresses.addAll(data.item2);
      }
    }

    try {
      var fullNode = _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.FullNodeWallet);
      var jellyFish = _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.JellyfishBullshit);
      var bip32 = _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.BIP32);
      var bip44 = _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.BIP44);

      var result = await Future.wait([fullNode, jellyFish, bip32, bip44]);

      for (var res in result) {
        checkIfExistingAndAddToList(res);
      }
    } catch (error) {
      //ignore
    }

    return Tuple2(walletAccounts, walletAddresses);
  }

  static Future<Tuple2<WalletAccount, List<WalletAddress>>> _restoreDerivationPath(
      int account, List<int> key, ApiService api, ChainType chain, ChainNet network, PathDerivationType pathDerivationType) async {
    final walletAccount = WalletAccount(Uuid().v4(),
        name: "${ChainHelper.chainTypeString(chain)}_${pathDerivationTypeString(pathDerivationType)}_${(account + 1)}",
        id: account,
        account: account,
        chain: chain,
        walletAccountType: WalletAccountType.HdAccount,
        derivationPathType: pathDerivationType,
        defaultAddressType: getDefaultAddressTypeForPathDerivation(pathDerivationType),
        selected: true);

    final p2sh = _restore(walletAccount, key, api, chain, network, AddressType.P2SHSegwit);
    final bech32 = _restore(walletAccount, key, api, chain, network, AddressType.Bech32);
    final legacy = _restore(walletAccount, key, api, chain, network, AddressType.Legacy);

    var all = await Future.wait([p2sh, bech32, legacy]);
    var ret = List<WalletAddress>.empty(growable: true);

    for (var add in all) {
      ret.addAll(add);
    }

    return Tuple2(walletAccount, ret);
  }

  static Future<List<WalletAddress>> _restore(WalletAccount account, Uint8List key, ApiService api, ChainType chain, ChainNet net, AddressType addressType) async {
    int i = 0;
    int maxEmpty = IWallet.MaxUnusedIndexScan;
    var startDate = DateTime.now();
    var addresses = List<WalletAddress>.empty(growable: true);

    do {
      try {
        var publicKeys = await HdWalletUtil.derivePublicKeysWithChange(
            key, account.account, IWallet.KeysPerQuery * i, chain, net, addressType, account.derivationPathType, IWallet.KeysPerQuery);
        var path = HdWalletUtil.derivePathsWithChange(account.account, IWallet.KeysPerQuery * i, account.derivationPathType, IWallet.KeysPerQuery);

        var transactions = await api.transactionService.getAddressesTransactions(ChainHelper.chainTypeString(chain), publicKeys);
        LogHelper.instance.d("($chain) [${account.derivationPathType}] found ${transactions.length} for path ${path.first} length ${IWallet.KeysPerQuery} (${publicKeys[0]})");

        for (final tx in transactions) {
          final keyIndex = publicKeys.indexWhere((item) => item == tx.address);
          var pathString = path[keyIndex];

          if (!addresses.any((element) => element.publicKey == tx.address)) {
            final walletAddress = WalletAddress(
                account: account.account,
                accountId: account.uniqueId,
                index: HdWalletUtil.getIndexFromPath(pathString),
                isChangeAddress: HdWalletUtil.isPathChangeAddress(pathString),
                chain: chain,
                network: net,
                publicKey: publicKeys[keyIndex],
                addressType: addressType);

            addresses.add(walletAddress);
          }
        }

        var accounts = await api.accountService.getAccounts(ChainHelper.chainTypeString(chain), publicKeys);
        LogHelper.instance.d("($chain) [${account.derivationPathType}] found ${accounts.length} for path ${path.first} length ${IWallet.KeysPerQuery} (${publicKeys[0]})");

        for (final accountBalance in accounts) {
          final keyIndex = publicKeys.indexWhere((item) => item == accountBalance.address);
          var pathString = path[keyIndex];

          if (!addresses.any((element) => element.publicKey == accountBalance.address)) {
            final walletAddress = WalletAddress(
                account: account.account,
                accountId: account.uniqueId,
                index: HdWalletUtil.getIndexFromPath(pathString),
                isChangeAddress: HdWalletUtil.isPathChangeAddress(pathString),
                chain: chain,
                network: net,
                publicKey: publicKeys[keyIndex],
                addressType: addressType);

            addresses.add(walletAddress);
          }
        }

        if (transactions.length == 0) {
          maxEmpty--;
        } else {
          maxEmpty = IWallet.MaxUnusedIndexScan;
        }
      } catch (e) {
        LogHelper.instance.e(e);
        maxEmpty--;
        throw e;
      } finally {
        i++;
      }
    } while (maxEmpty > 0);

    var endDate = DateTime.now();

    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("restore took ${diff / 1000} seconds");

    return addresses;
  }
}
