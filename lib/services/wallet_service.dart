import 'dart:async';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/crypto/wallet/wallet-restore.dart';
import 'package:saiive.live/crypto/wallet/wallet.dart';
import 'package:saiive.live/network/account_history_service.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:saiive.live/network/model/account_history.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

abstract class IWalletService {
  Future init();
  Future<bool> isRestoreNeeded();
  Future syncAll();

  Future<bool> hasAccounts();
  Future<List<WalletAccount>> getAccounts();

  Future<List<WalletAddress>> getPublicKeysFromAccount(WalletAccount account);
  Future<WalletAddress> getNextWalletAddress(ChainType chainType, bool isChangeAddress, AddressType addressType);

  Future<String> getPublicKey(ChainType chainType, AddressType addressType);
  Future<String> createAndSend(ChainType chainType, int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false});
  Future<List<String>> getPublicKeys(ChainType chainType);

  Future<List<Tuple2<List<WalletAccount>, List<WalletAddress>>>> restore(ChainNet network);

  Future close();
  Future destroy();

  Future<WalletAccount> addAccount(WalletAccount account);
  Future<WalletAddress> updateAddress(WalletAddress account);
  Future<List<AccountHistory>> getAccountHistory(ChainType chain, String token, bool includeRewards);

  Future<Map<String, bool>> getIsAlive();
}

class WalletService implements IWalletService {
  BitcoinWallet _bitcoinWallet;
  DeFiChainWallet _defiWallet;

  List<IWallet> _wallets = List<IWallet>.empty(growable: true);

  @override
  Future init() async {
    _wallets.clear();
    _bitcoinWallet = sl.get<BitcoinWallet>();
    _defiWallet = sl.get<DeFiChainWallet>();


    for (final wallet in _wallets) {
      await wallet.close();
    }
    
    _wallets.add(_bitcoinWallet);
    _wallets.add(_defiWallet);

    await Future.wait([_bitcoinWallet.init(), _defiWallet.init()]);
  }

  Future<bool> isRestoreNeeded() async {
    var hasAnyoneMissingAccounts = false;
    for (var wallet in _wallets) {
      var hasAccounts = await wallet.hasAccounts();

      if (!hasAccounts) {
        hasAnyoneMissingAccounts = true;
        break;
      }
    }
    return hasAnyoneMissingAccounts;
  }

  @override
  Future close() async {
    _bitcoinWallet.close();
    _defiWallet.close();
  }

  @override
  Future<String> createAndSend(ChainType chainType, int amount, String token, String to, {StreamController<String> loadingStream, bool sendMax = false}) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.createAndSend(amount, token, to, loadingStream: loadingStream, sendMax: sendMax);
    }
    return _bitcoinWallet.createAndSend(amount, token, to, loadingStream: loadingStream, sendMax: sendMax);
  }

  @override
  Future<List<WalletAccount>> getAccounts() async {
    var defiAccounts = await _defiWallet.getAccounts();
    var btcAccounts = await _bitcoinWallet.getAccounts();

    var ret = List<WalletAccount>.from(defiAccounts);
    ret.addAll(btcAccounts);

    return ret;
  }

  @override
  Future<WalletAddress> getNextWalletAddress(ChainType chainType, bool isChangeAddress, AddressType addressType) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.getNextWalletAddress(addressType, isChangeAddress);
    }
    return _bitcoinWallet.getNextWalletAddress(addressType, isChangeAddress);
  }

  @override
  Future<String> getPublicKey(ChainType chainType, AddressType addressType) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.getPublicKey(false, addressType);
    }
    return _bitcoinWallet.getPublicKey(false, addressType);
  }

  @override
  Future<List<String>> getPublicKeys(ChainType chainType) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.getPublicKeys();
    }
    return _bitcoinWallet.getPublicKeys();
  }

  @override
  Future<List<WalletAddress>> getPublicKeysFromAccount(WalletAccount account) {
    if (account.chain == ChainType.DeFiChain) {
      return _defiWallet.getPublicKeysFromAccounts(account);
    }
    return _bitcoinWallet.getPublicKeysFromAccounts(account);
  }

  @override
  Future<bool> hasAccounts() async {
    var btcHasAccounts = await _bitcoinWallet.hasAccounts();
    var defiHasAccounts = await _defiWallet.hasAccounts();

    return btcHasAccounts && defiHasAccounts;
  }

  @override
  Future syncAll() async {
    await Future.wait([_defiWallet.syncAll(), _bitcoinWallet.syncAll()]);
  }

  @override
  Future<WalletAddress> updateAddress(WalletAddress address) {
    if (address.chain == ChainType.DeFiChain) {
      return _defiWallet.updateAddress(address);
    }
    return _bitcoinWallet.updateAddress(address);
  }

  @override
  Future<WalletAccount> addAccount(WalletAccount account) {
    if (account.chain == ChainType.DeFiChain) {
      return _defiWallet.addAccount(account);
    }
    return _bitcoinWallet.addAccount(account);
  }

  @override
  Future<List<Tuple2<List<WalletAccount>, List<WalletAddress>>>> restore(ChainNet network) {
    var bitcoinWallet = sl.get<BitcoinWallet>();
    var defiWallet = sl.get<DeFiChainWallet>();

    var restoreBtc = _restoreWallet(ChainType.Bitcoin, network, bitcoinWallet);
    var restoreDefi = _restoreWallet(ChainType.DeFiChain, network, defiWallet);

    return Future.wait([restoreBtc, restoreDefi]);
  }

  Future<List<AccountHistory>> getAccountHistory(ChainType chain, String token, bool includeRewards) async {
    if (chain == ChainType.DeFiChain) {
      var pubKeyList = await _defiWallet.getPublicKeys();
      return await sl.get<IAccountHistoryService>().getAddressesHistory('DFI', pubKeyList, token, !includeRewards);
    }
    return List<AccountHistory>.empty();
  }

  Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> _restoreWallet(ChainType chain, ChainNet network, IWallet wallet) async {
    var dataMap = Map();
    dataMap["chain"] = chain;
    dataMap["network"] = network;
    dataMap["seed"] = await sl.get<IVault>().getSeed();
    dataMap["password"] = ""; //await sl.get<Vault>().getSecret();
    dataMap["apiService"] = sl.get<ApiService>();

    var result = await compute(_searchAccounts, dataMap);

    var db = await sl.get<IWalletDatabaseFactory>().getDatabase(chain, network);
    for (var element in result.item1) {
      element.selected = true;
      await db.addOrUpdateAccount(element);
    }
    for (var address in result.item2) {
      await db.addAddress(address);
    }

    if (result.item1.length == 0) {
      final walletAccount = WalletAccount(
          uniqueId: Uuid().v4(), id: 0, chain: chain, account: 0, walletAccountType: WalletAccountType.HdAccount, name: ChainHelper.chainTypeString(chain), selected: true);
      await db.addOrUpdateAccount(walletAccount);
    }

    await wallet.init();
    await wallet.syncAll();
    return result;
  }

  static Future<Tuple2<List<WalletAccount>, List<WalletAddress>>> _searchAccounts(Map dataMap) async {
    final ret = await WalletRestore.restore(
      dataMap["chain"],
      dataMap["network"],
      dataMap["seed"],
      dataMap["password"],
      dataMap["apiService"],
    );

    return ret;
  }

  @override
  Future destroy() async {
    await _bitcoinWallet.getDatabase().destroy();
    await _defiWallet.getDatabase().destroy();
  }

  @override
  Future<Map<String, bool>> getIsAlive() async {
    var ret = Map<String, bool>();

    for (final wallet in _wallets) {
      var isAlive = await wallet.isAlive();

      ret.putIfAbsent(wallet.walletType, () => isAlive);
    }

    return ret;
  }
}
