import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/model/wallet_address.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:hex/hex.dart';
import 'package:tuple/tuple.dart';

class HdWallet extends IHdWallet {
  final String _password;
  final WalletAccount _account;
  final ChainType _chain;
  final ChainNet _network;
  final String _seed;
  final ApiService _apiService;

  HdWallet(this._password, this._account, this._chain, this._network, this._seed, this._apiService);

  Future<List<String>> getPublicKeys() async {
    final key = HEX.decode(_seed);
    var keys = await HdWalletUtil.derivePublicKeysWithChange(key, _account.account, 0, _chain, _network, IWallet.KeysPerQuery);
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

  Future _checkAndCreateIfExists(IWalletDatabase walletDatabase, Uint8List seed, int index, bool isChangeAddress) async {
    final alreadyExists = await walletDatabase.addressExists(_account.account, isChangeAddress, index);

    if (!alreadyExists) {
      final pubKey = await HdWalletUtil.derivePublicKey(seed, _account.id, isChangeAddress, index, _chain, _network);

      await walletDatabase.addAddress(_createAddress(isChangeAddress, index, pubKey));
    }
  }

  WalletAddress _createAddress(bool isChangeAddress, int index, String pubKey) {
    return WalletAddress(account: _account.id, isChangeAddress: isChangeAddress, index: index, chain: _chain, publicKey: pubKey, network: _network);
  }

  @override
  Future<String> nextFreePublicKey(IWalletDatabase database, bool isChangeAddress) async {
    final nextIndex = await database.getNextFreeIndex(_account.account);

    if (!await database.addressExists(_account.account, isChangeAddress, nextIndex)) {
      throw ArgumentError("not allowed to happen for now");
    }
    var address = await database.getWalletAddressById(_account.account, isChangeAddress, nextIndex);

    return address.publicKey;
  }

  @override
  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress) async {
    final nextIndex = await database.getNextFreeIndex(_account.account);

    return Tuple3<int, bool, int>(_account.account, isChangeAddress, nextIndex);
  }

  Future _syncWallet(IWalletDatabase database, Function(List<String>) work) async {
    var startDate = DateTime.now();

    final walletAddresses = await database.getWalletAddresses(_account.account);

    final walletLen = walletAddresses.length;
    var i = 0;
    var remainingAddresses = walletLen;
    do {
      remainingAddresses = (walletLen - IWallet.KeysPerQuery * (i + 1));
      final subListLen = min(IWallet.KeysPerQuery * (i + 1), walletLen);
      final startSubList = i * IWallet.KeysPerQuery;
      final addresses = walletAddresses.sublist(startSubList, subListLen).map((e) => e.publicKey).toList();

      await work(addresses);
      i++;
    } while (remainingAddresses >= 0);
    var endDate = DateTime.now();

    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("sync took ${diff / 1000} seconds");
  }

  @override
  Future syncWallet(IWalletDatabase database) async {
    await database.clearUnspentTransactions();
    await database.clearAccountBalances();

    await _syncWallet(database, (addresses) async {
      final utxo = await _apiService.transactionService.getUnspentTransactionOutputs(ChainHelper.chainTypeString(_chain), addresses);
      final balances = await _apiService.accountService.getAccounts(ChainHelper.chainTypeString(_chain), addresses);

      utxo.forEach((element) async {
        await database.addUnspentTransaction(element);
      });

      for (final acc in balances) {
        acc.accounts.forEach((element) async {
          await database.setAccountBalance(element);
        });
      }
    });
  }

  @override
  Future syncWalletTransactions(IWalletDatabase database) async {
    await database.clearTransactions();

    await _syncWallet(database, (addresses) async {
      final txs = await _apiService.transactionService.getAddressesTransactions(ChainHelper.chainTypeString(_chain), addresses);

      txs.forEach((element) async {
        await database.addTransaction(element);
      });
    });
  }
}
