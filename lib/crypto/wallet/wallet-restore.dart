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

    var fullNode = await _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.FullNodeWallet);
    checkIfExistingAndAddToList(fullNode);

    var jellyFish = await _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.JellyfishBullshit);
    checkIfExistingAndAddToList(jellyFish);

    var bip32 = await _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.BIP32);
    checkIfExistingAndAddToList(bip32);

    var bip44 = await _restoreDerivationPath(account, key, api, chain, network, PathDerivationType.BIP44);
    checkIfExistingAndAddToList(bip44);

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

    final addresses = await _restore(walletAccount, key, api, chain, network, AddressType.P2SHSegwit);
    final addressesBech32 = await _restore(walletAccount, key, api, chain, network, AddressType.Bech32);
    final legacy = await _restore(walletAccount, key, api, chain, network, AddressType.Legacy);

    addresses.addAll(legacy);
    addresses.addAll(addressesBech32);
    return Tuple2(walletAccount, addresses);
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

        if (transactions.length == 0) {
          maxEmpty--;
        } else {
          return addresses;
        }
      } catch (e) {
        LogHelper.instance.e(e);
        maxEmpty--;
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
