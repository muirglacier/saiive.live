import 'dart:async';

import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database_factory.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/bitcoin_wallet.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/account_history_service.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account_history.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/network/model/transaction_data.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

abstract class IWalletService {
  Future init();

  Future syncAll();

  Future<bool> hasAccounts();
  Future<List<WalletAccount>> getAccounts();

  Future<String> getPublicKey(ChainType chainType);
  Future<TransactionData> createAndSend(ChainType chainType, int amount, String token, String to, {StreamController<String> loadingStream});
  Future<List<String>> getPublicKeys(ChainType chainType);

  Future<List<Tuple2<List<WalletAccount>, List<WalletAddress>>>> restore(ChainNet network);

  Future close();
  Future destroy();

  Future<WalletAccount> addAccount({String name, int account, ChainType chain});
  Future<List<AccountHistory>> getAccountHistory(ChainType chain, String token, bool includeRewards);
}

class WalletService implements IWalletService {
  BitcoinWallet _bitcoinWallet;
  DeFiChainWallet _defiWallet;

  @override
  Future init() async {
    _bitcoinWallet = sl.get<BitcoinWallet>();
    _defiWallet = sl.get<DeFiChainWallet>();

    await Future.wait([_bitcoinWallet.init(), _defiWallet.init()]);
  }

  @override
  Future close() async {
    _bitcoinWallet.close();
    _defiWallet.close();
  }

  @override
  Future<TransactionData> createAndSend(ChainType chainType, int amount, String token, String to, {StreamController<String> loadingStream}) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.createAndSend(amount, token, to, loadingStream: loadingStream);
    }
    return _bitcoinWallet.createAndSend(amount, token, to, loadingStream: loadingStream);
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
  Future<String> getPublicKey(ChainType chainType) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.getPublicKey();
    }
    return _bitcoinWallet.getPublicKey();
  }

  @override
  Future<List<String>> getPublicKeys(ChainType chainType) {
    if (chainType == ChainType.DeFiChain) {
      return _defiWallet.getPublicKeys();
    }
    return _bitcoinWallet.getPublicKeys();
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
  Future<WalletAccount> addAccount({String name, int account, ChainType chain}) {
    if (chain == ChainType.DeFiChain) {
      return _defiWallet.addAccount(name, account);
    }
    return _bitcoinWallet.addAccount(name, account);
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

    var isFirst = true;
    var db = await sl.get<IWalletDatabaseFactory>().getDatabase(chain, network);
    for (var element in result.item1) {
      await db.addAccount(name: element.name, account: element.account, chain: chain, isSelected: isFirst);

      isFirst = false;
    }
    for (var address in result.item2) {
      await db.addAddress(address);
    }

    if (result.item1.length == 0) {
      await db.addAccount(name: ChainHelper.chainTypeString(chain), account: 0, chain: chain);
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
}
