import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/hdWallet.dart';
import 'package:saiive.live/crypto/wallet/wallet.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:saiive.live/network/model/key_account_wrapper.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:hex/hex.dart';
import 'package:tuple/tuple.dart';

class HdWallet extends IHdWallet {
  final String _password;
  final WalletAccount _account;
  final ChainType _chain;
  final ChainNet _network;
  final String _seed;
  final ApiService _apiService;

  int _localNextIndex = 0;

  HdWallet(this._password, this._account, this._chain, this._network, this._seed, this._apiService);

  Future<List<String>> getPublicKeys(IWalletDatabase walletDatabase) async {
    final walletAddresses = await walletDatabase.getWalletAddresses(_account.account);
    final allAddresses = walletAddresses.map((e) => e.publicKey).toList();

    return allAddresses;
  }

  @override
  Future init(IWalletDatabase walletDatabase) async {
    var addresses = await walletDatabase.getWalletAddresses(_account.account);

    if (addresses.length >= walletDatabase.getAddressCreationCount()) {
      for (final address in addresses) {
        final pubKey = address.publicKey;
        final pathString = address.account.toString() + "/" + (address.isChangeAddress ? "1" : "0") + "/" + address.index.toString();
        LogHelper.instance.i("Wallet $_chain uses address $pubKey at $pathString");
      }

      return;
    }

    final seed = HEX.decode(_seed);
    for (int i = 0; i < walletDatabase.getAddressCreationCount(); i++) {
      await _checkAndCreateIfExists(walletDatabase, seed, i, true, AddressType.P2SHSegwit);
      await _checkAndCreateIfExists(walletDatabase, seed, i, false, AddressType.P2SHSegwit);
    }
  }

  Future _checkAndCreateIfExists(IWalletDatabase walletDatabase, Uint8List seed, int index, bool isChangeAddress, AddressType addressType) async {
    final alreadyExists = await walletDatabase.addressExists(_account.account, isChangeAddress, index, addressType);

    if (!alreadyExists) {
      final pubKey = await HdWalletUtil.derivePublicKey(seed, _account.id, isChangeAddress, index, _chain, _network, addressType);

      await walletDatabase.addAddress(_createAddress(isChangeAddress, index, pubKey, addressType));
    }
  }

  WalletAddress _createAddress(bool isChangeAddress, int index, String pubKey, AddressType addressType) {
    return WalletAddress(account: _account.id, isChangeAddress: isChangeAddress, index: index, chain: _chain, publicKey: pubKey, network: _network, addressType: addressType);
  }

  @override
  Future<String> nextFreePublicKey(IWalletDatabase database, SharedPrefsUtil sharedPrefs, bool isChangeAddress, AddressType addressType) async {
    var nextIndex = await sharedPrefs.getAddressIndex(isChangeAddress);

    var address = await getNextFreePublicKey(database, nextIndex, sharedPrefs, isChangeAddress, addressType);

    return address.publicKey;
  }

  Future<WalletAddress> getNextFreePublicKey(IWalletDatabase database, int startIndex, SharedPrefsUtil sharedPrefs, bool isChangeAddress, AddressType addressType) async {
    if (!await database.addressExists(_account.account, isChangeAddress, startIndex, addressType)) {
      //overflow indexes....start again with 0
      await sharedPrefs.setAddressIndex(0, isChangeAddress);
      startIndex = 0;

      return await database.getWalletAddressById(_account.account, isChangeAddress, 0, addressType);
    }

    var address = await database.getWalletAddressById(_account.account, isChangeAddress, startIndex, addressType);
    var addressUsed = await database.addressAlreadyUsed(address.publicKey);

    if (addressUsed) {
      return await getNextFreePublicKey(database, startIndex + 1, sharedPrefs, isChangeAddress, addressType);
    }

    await sharedPrefs.setAddressIndex(startIndex, isChangeAddress);
    return address;
  }

  @override
  Future<Tuple3<int, bool, int>> nextFreePublicKeyRaw(IWalletDatabase database, bool isChangeAddress, AddressType addressType) async {
    final nextIndex = await database.getNextFreeIndex(_account.account);

    return Tuple3<int, bool, int>(_account.account, isChangeAddress, nextIndex);
  }

  Future _syncWallet(IWalletDatabase database, Function(List<String>, int, int) work, {StreamController<String> loadingStream}) async {
    var startDate = DateTime.now();

    final walletAddresses = await database.getWalletAddresses(_account.account);

    final walletLen = walletAddresses.length;
    var i = 0;
    var remainingAddresses = walletLen;

    final allAddresses = walletAddresses.map((e) => e.publicKey).toList().join("\",\"");

    LogHelper.instance.d("AllAddress for wallet: $allAddresses");

    do {
      remainingAddresses = (walletLen - IWallet.KeysPerQuery * (i + 1));
      final subListLen = min(IWallet.KeysPerQuery * (i + 1), walletLen);
      final startSubList = i * IWallet.KeysPerQuery;
      final addresses = walletAddresses.sublist(startSubList, subListLen).map((e) => e.publicKey).toList();

      final addressesStr = addresses.join("\",\"");

      LogHelper.instance.d("Address: $addressesStr");

      await work(addresses, startSubList, walletLen);
      i++;
    } while (remainingAddresses >= 0);
    var endDate = DateTime.now();

    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

    print("sync took ${diff / 1000} seconds");
  }

  @override
  Future syncWallet(IWalletDatabase database, {StreamController<String> loadingStream}) async {
    loadingStream?.add(S.current.wallet_operation_refresh_utxo);

    var newUtxos = List<Transaction>.empty(growable: true);
    var newBalance = List<KeyAccountWrapper>.empty(growable: true);

    await _syncWallet(database, (addresses, pos, max) async {
      loadingStream?.add(S.current.wallet_operation_refresh_addresses(pos, max));
      final utxo = await _apiService.transactionService.getUnspentTransactionOutputs(ChainHelper.chainTypeString(_chain), addresses);

      newUtxos.addAll(utxo);

      if (_chain == ChainType.DeFiChain) {
        final balances = await _apiService.accountService.getAccounts(ChainHelper.chainTypeString(_chain), addresses);
        newBalance.addAll(balances);
      }
    }, loadingStream: loadingStream);

    await database.clearUnspentTransactions();
    newUtxos.forEach((element) async {
      await database.addUnspentTransaction(element);
      print("tx with id ${element.mintTxId} has ${element.confirmations} confirmations");
    });

    await database.clearAccountBalances();
    for (final acc in newBalance) {
      for (final element in acc.accounts) {
        await database.setAccountBalance(element);
      }
    }

    loadingStream?.add(S.current.wallet_operation_refresh_utxo_done);
  }

  @override
  Future syncWalletTransactions(IWalletDatabase database, {StreamController<String> loadingStream}) async {
    await database.clearTransactions();

    loadingStream?.add(S.current.wallet_operation_refresh_utxo);
    await _syncWallet(database, (addresses, pos, max) async {
      loadingStream?.add(S.current.wallet_operation_refresh_tx(pos, max));
      final txs = await _apiService.transactionService.getAddressesTransactions(ChainHelper.chainTypeString(_chain), addresses);

      txs.forEach((element) async {
        await database.addTransaction(element);
      });
    }, loadingStream: loadingStream);
    loadingStream?.add(S.current.wallet_operation_refresh_utxo_done);
  }
}
