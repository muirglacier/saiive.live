import 'dart:isolate';
import 'dart:typed_data';
import 'dart:async';
import 'package:defichaindart/defichaindart.dart';
import 'package:easy_isolate/easy_isolate.dart';
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

class StartSyncMessage {
  final ChainType chain;
  final ChainNet network;
  final String seed;
  final String password;
  final ApiService apiService;

  StartSyncMessage(this.chain, this.network, this.seed, this.password, this.apiService);
}

class WalletRestoreMessage {
  final String message;
  final ChainType chainType;
  final ChainNet chainNet;
  final WalletAccount account;
  final PathDerivationType pathType;
  final AddressType addressType;

  WalletRestoreMessage(this.message, this.chainType, this.chainNet, this.account, this.pathType, this.addressType);
}

class WalletRestore {
  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> startRestore(dynamic message, SendPort sendPort, SendErrorFunction onSendError) async {
    return await restore(sendPort, message.chain, message.network, message.seed, message.password, message.apiService);
  }

  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> restore(SendPort sendPort, ChainType chain, ChainNet network, String seed, String password, ApiService apiService,
      {List<int> existingAccounts}) async {
    assert(chain != null);
    assert(network != null);
    assert(seed != null);
    assert(password != null);
    assert(apiService != null);

    var startDate = DateTime.now();

    int i = 0;
    int max = chain == ChainType.DeFiChain ? IWallet.MaxUnusedAccountScan : IWallet.MaxUnusedAccountScanBitcoin;
    final api = apiService;

    final ret = List<WalletAccount>.empty(growable: true);
    final walletAddresses = List<WalletAddress>.empty(growable: true);

    final key = HEX.decode(mnemonicToSeedHex(seed));
    if (existingAccounts == null) {
      existingAccounts = [];
    }

    do {
      if (!existingAccounts.contains(i)) {
        var all = await _restoreAll(sendPort, i, key, api, chain, network);

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

    var diff = DateTime.now().millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;
    print("complete restore took ${diff / 1000} seconds");
    return Tuple2(ret, walletAddresses);
  }

  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> _restoreAll(
      SendPort sendPort, int account, List<int> key, ApiService api, ChainType chain, ChainNet network) async {
    var walletAccounts = List<WalletAccount>.empty(growable: true);
    var walletAddresses = List<WalletAddress>.empty(growable: true);

    void checkIfExistingAndAddToList(Tuple2<WalletAccount, List<WalletAddress>> data) {
      if (data.item2.isNotEmpty) {
        walletAccounts.add(data.item1);
        walletAddresses.addAll(data.item2);
      }
    }

    try {
      var fullNode = await _restoreDerivationPath(sendPort, account, key, api, chain, network, PathDerivationType.FullNodeWallet);
      var jellyFish = await _restoreDerivationPath(sendPort, account, key, api, chain, network, PathDerivationType.JellyfishBullshit);
      var bip32 = await _restoreDerivationPath(sendPort, account, key, api, chain, network, PathDerivationType.BIP32);
      var bip44 = await _restoreDerivationPath(sendPort, account, key, api, chain, network, PathDerivationType.BIP44);

      checkIfExistingAndAddToList(fullNode);
      checkIfExistingAndAddToList(jellyFish);
      checkIfExistingAndAddToList(bip32);
      checkIfExistingAndAddToList(bip44);
    } catch (error) {
      //ignore
    }

    return Tuple2(walletAccounts, walletAddresses);
  }

  static Future<Tuple2<WalletAccount, List<WalletAddress>>> _restoreDerivationPath(
      SendPort sendPort, int account, List<int> key, ApiService api, ChainType chain, ChainNet network, PathDerivationType pathDerivationType) async {
    final walletAccount = WalletAccount(Uuid().v4(),
        name: "${ChainHelper.chainTypeString(chain)}_${pathDerivationTypeString(pathDerivationType)}_${(account + 1)}",
        id: account,
        account: account,
        chain: chain,
        walletAccountType: WalletAccountType.HdAccount,
        derivationPathType: pathDerivationType,
        defaultAddressType: getDefaultAddressTypeForPathDerivation(pathDerivationType),
        selected: true);

    var startDate = DateTime.now();

    final p2sh = await _restore(sendPort, walletAccount, key, api, chain, network, AddressType.P2SHSegwit, pathDerivationType);
    final bech32 = await _restore(sendPort, walletAccount, key, api, chain, network, AddressType.Bech32, pathDerivationType);
    final legacy = await _restore(sendPort, walletAccount, key, api, chain, network, AddressType.Legacy, pathDerivationType);
    var ret = List<WalletAddress>.empty(growable: true);

    ret.addAll(p2sh);
    ret.addAll(bech32);
    ret.addAll(legacy);

    var endDate = DateTime.now();

    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("restore took ${pathDerivationTypeString(pathDerivationType)}  ${diff / 1000} seconds");

    return Tuple2(walletAccount, ret);
  }

  static Future<List<WalletAddress>> _restore(SendPort sendPort, WalletAccount account, Uint8List key, ApiService api, ChainType chain, ChainNet net, AddressType addressType,
      PathDerivationType pathDerivationType) async {
    int i = 0;
    int maxEmpty = chain == ChainType.DeFiChain ? IWallet.MaxUnusedIndexScan : IWallet.MaxUnusedIndexScanBitcoin;

    var keysPerQuery = chain == ChainType.DeFiChain ? IWallet.KeysPerQuery : IWallet.KeysPerQueryBitcoin;
    var startDate = DateTime.now();
    var addresses = List<WalletAddress>.empty(growable: true);

    sendPort?.send(WalletRestoreMessage("restore", chain, net, account, pathDerivationType, addressType));

    do {
      try {
        var publicKeys = await HdWalletUtil.derivePublicKeysWithChange(key, account.account, keysPerQuery * i, chain, net, addressType, account.derivationPathType, keysPerQuery);
        var path = HdWalletUtil.derivePathsWithChange(account.account, keysPerQuery * i, account.derivationPathType, keysPerQuery);

        var transactions = await api.accountService.getAccounts(ChainHelper.chainTypeString(chain), publicKeys);
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

        // var accounts = await api.accountService.getAccounts(ChainHelper.chainTypeString(chain), publicKeys);
        // LogHelper.instance.d("($chain) [${account.derivationPathType}] found ${accounts.length} for path ${path.first} length ${IWallet.KeysPerQuery} (${publicKeys[0]})");

        // for (final accountBalance in accounts) {
        //   final keyIndex = publicKeys.indexWhere((item) => item == accountBalance.address);
        //   var pathString = path[keyIndex];

        //   if (!addresses.any((element) => element.publicKey == accountBalance.address)) {
        //     final walletAddress = WalletAddress(
        //         account: account.account,
        //         accountId: account.uniqueId,
        //         index: HdWalletUtil.getIndexFromPath(pathString),
        //         isChangeAddress: HdWalletUtil.isPathChangeAddress(pathString),
        //         chain: chain,
        //         network: net,
        //         publicKey: publicKeys[keyIndex],
        //         addressType: addressType);

        //     addresses.add(walletAddress);
        //   }
        // }

        if (transactions.length == 0) {
          maxEmpty--;
        } else {
          maxEmpty = chain == ChainType.DeFiChain ? IWallet.MaxUnusedIndexScan : IWallet.MaxUnusedIndexScanBitcoin;
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

    print("restore took ${pathDerivationTypeString(pathDerivationType)} ${addressTypeToString(addressType)} ${diff / 1000} seconds");

    return addresses;
  }
}
