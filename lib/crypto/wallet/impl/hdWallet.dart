import 'dart:async';
import 'dart:typed_data';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:hex/hex.dart';
import 'package:defichainwallet/helper/logger/LogHelper.dart';
import 'package:tuple/tuple.dart';

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

  Future<List<String>> getPublicKeys() async {
    final key = HEX.decode(_seed);
    var keys = await HdWalletUtil.derivePublicKeysWithChange(
        key, _account.account, 0, _chain, _network, IWallet.KeysPerQuery);
    var pubKeyList = keys.map((item) => item).toList();

    return pubKeyList;
  }

  @override
  Future init(IWalletDatabase walletDatabase) async {
    var addresses = await walletDatabase.getWalletAddresses(_account.account);

    if (addresses.length >= walletDatabase.getAddressCreationCount()) {
      return;
    }

    final seed = HEX.decode(_seed);
    for (int i = 0; i <= walletDatabase.getAddressCreationCount(); i++) {
      await _checkAndCreateIfExists(walletDatabase, seed, i, true);
      await _checkAndCreateIfExists(walletDatabase, seed, i, false);
    }
  }

  Future _checkAndCreateIfExists(IWalletDatabase walletDatabase, Uint8List seed,
      int index, bool isChangeAddress) async {

    final alreadyExists =
        await walletDatabase.addressExists(_account.account, isChangeAddress, index);

    if (!alreadyExists) {
      final pubKey = await HdWalletUtil.derivePublicKey(
          seed, _account.id, isChangeAddress, index, _chain, _network);

      await walletDatabase.addAddress(_createAddress(isChangeAddress, index, pubKey));
    }
  }

  WalletAddress _createAddress(bool isChangeAddress, int index, String pubKey) {
    return WalletAddress(
        account: _account.id,
        isChangeAddress: isChangeAddress,
        index: index,
        chain: _chain,
        publicKey: pubKey,
        network: _network);
  }

  @override
  Future<List<Account>> syncBalance() async {
    int empty = 0;
    int i = 0;
    _nextFreeIndex = 0;

    var startDate = DateTime.now();
    final key = HEX.decode(_seed);
    final apiService = _apiService;
    var balanceList = List<Account>.empty(growable: true);

    do {
      try {
        var keys = await HdWalletUtil.derivePublicKeysWithChange(
            key,
            _account.account,
            IWallet.KeysPerQuery * i,
            _chain,
            _network,
            IWallet.KeysPerQuery);
        var path = HdWalletUtil.derivePathsWithChange(
            _account.account, IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
        var pubKeyList = keys.map((item) => item).toList();
        var accountBalance = await apiService.accountService
            .getAccounts(ChainHelper.chainTypeString(_chain), pubKeyList);

        LogHelper.instance.d(
            "found ${accountBalance.length} for path ${path.first} length ${IWallet.KeysPerQuery}");

        var anyBalanceFound = false;
        for (final balance in accountBalance) {
          anyBalanceFound = true;
          balanceList.addAll(balance.accounts);

          for (final acc in balance.accounts) {
            acc.chain = ChainHelper.chainTypeString(_chain);
            acc.network = ChainHelper.chainNetworkString(_network);
          }
        }

        if (anyBalanceFound) {
          _nextFreeIndex++;
        } else {
          empty++;
        }
      } catch (e) {
        LogHelper.instance.e("Error syncBalance", e);
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

  Future<List<tx.Transaction>> syncTransactions() async {
    int empty = 0;
    int i = 0;
    _nextFreeIndex = 0;

    var startDate = DateTime.now();
    final key = HEX.decode(_seed);
    final apiService = _apiService;
    var txList = List<tx.Transaction>.empty(growable: true);

    do {
      try {
        var keys = await HdWalletUtil.derivePublicKeysWithChange(
            key,
            _account.account,
            IWallet.KeysPerQuery * i,
            _chain,
            _network,
            IWallet.KeysPerQuery);

        var path = HdWalletUtil.derivePathsWithChange(
            _account.account, IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
        var pubKeyList = keys.map((item) => item).toList();

        var txs = await apiService.transactionService.getAddressesTransactions(
            ChainHelper.chainTypeString(_chain), pubKeyList);

        LogHelper.instance.d(
            "found ${txs.length} for path ${path.first} length ${IWallet.KeysPerQuery}");
        txList.addAll(txs);
        var anyBalanceFound = txs.length > 0;

        if (anyBalanceFound) {
          _nextFreeIndex++;
        } else {
          empty++;
        }
      } catch (e) {
        LogHelper.instance.e("error sync txs", e);
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

  Future<List<tx.Transaction>> syncUnspentTransactions() async {
    int empty = 0;
    int i = 0;
    _nextFreeIndex = 0;

    var startDate = DateTime.now();
    final key = HEX.decode(_seed);
    final apiService = _apiService;
    var txList = List<tx.Transaction>.empty(growable: true);

    do {
      try {
        var keys = await HdWalletUtil.derivePublicKeysWithChange(
            key,
            _account.account,
            IWallet.KeysPerQuery * i,
            _chain,
            _network,
            IWallet.KeysPerQuery);

        var path = HdWalletUtil.derivePathsWithChange(
            _account.account, IWallet.KeysPerQuery * i, IWallet.KeysPerQuery);
        var pubKeyList = keys.map((item) => item).toList();

        var txs = await apiService.transactionService
            .getUnspentTransactionOutputs(
                ChainHelper.chainTypeString(_chain), pubKeyList);

        LogHelper.instance.d(
            "found ${txs.length} for path ${path.first} length ${IWallet.KeysPerQuery}");
        txList.addAll(txs);
        var anyBalanceFound = txs.length > 0;

        if (anyBalanceFound) {
          _nextFreeIndex++;
        } else {
          empty++;
        }
      } catch (e) {
        LogHelper.instance.e("error sync txs", e);
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
  Future<String> nextFreePublicKey(
      IWalletDatabase database, bool isChangeAddress) async {
    final nextIndex = await database.getNextFreeIndex(_account.account);

    if (!await database.addressExists(
        _account.account, isChangeAddress, nextIndex)) {
      throw ArgumentError("not allowed to happen for now");
    }
    var address = await database.getWalletAddressById(
        _account.account, isChangeAddress, nextIndex);

    return address.publicKey;
  }

  @override
  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(
      IWalletDatabase database, bool isChangeAddress) async {
    final nextIndex = await database.getNextFreeIndex(_account.account);

    return Tuple3<int, bool, int>(_account.account, isChangeAddress, nextIndex);
  }
}
