import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:defichainwallet/network/model/vault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter/foundation.dart';

class Wallet extends IWallet {
  Map<int, IHdWallet> _wallets = Map<int, IHdWallet>();

  int _account;
  final ChainType _chain;
  ChainNet _network;

  String _password;
  String _seed;
  ApiService _apiService;
  IWalletDatabase _walletDatabase;

  Wallet(this._chain) {
    _apiService = sl.get<ApiService>();
    _walletDatabase = sl.get<IWalletDatabase>();
  }

  @override
  Future init() async {

    _password = ""; // TODO
    _seed = await sl.get<Vault>().getSeed();
    _network = await sl.get<SharedPrefsUtil>().getChainNetwork();
    _account = 0; //default account, for now only 0!

    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(_password, account, _chain, _network,
          mnemonicToSeedHex(_seed), _apiService);

      _wallets.putIfAbsent(account.account, () => wallet);
    }
  }

  @override
  void setWorkingAccount(int account) {
    _account = account;
  }

  @override
  Future<String> getPublicKey() async {
    return getPublicKeyFromAccount(_account);
  }

  @override
  Future<String> getPublicKeyFromAccount(int account) async {
    assert(_wallets.containsKey(account));

    if (_wallets.containsKey(account)) {
      return await _wallets[account].nextFreePublicKey(_walletDatabase);
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> syncBalance() async {
    var startDate = DateTime.now();
    var ret = List<Account>();
    try {
      for (final wallet in _wallets.values) {
        var balance = await wallet.syncBalance();
        ret.addAll(balance);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return ret;
  }

  @override
  Future<WalletAccount> addAccount(String name, int account) {
    return _walletDatabase.addAccount(
        name: name, account: account, chain: _chain);
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    return _walletDatabase.getAccounts();
  }

  @override
  Future<List<WalletAccount>> searchAccounts() async {
    var accounts = await getAccounts();
    accounts.sort((a, b) => a.id.compareTo(b.id));

    var accountIdList = accounts.map((e) => e.id).toList();

    var unusedAccounts = await WalletRestore.restore(
        _chain, _network, _seed, _password, _apiService,
        existingAccounts: accountIdList);

    unusedAccounts.sort((a, b) => a.id.compareTo(b.id));

    if (unusedAccounts.isEmpty) {
      var lastItem = accounts.last;

      unusedAccounts.add(WalletAccount(
          account: lastItem.account + 1,
          id: -1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) +
              (lastItem.account + 2).toString()));
    } else {
      var lastItem = unusedAccounts.last;

      unusedAccounts.add(WalletAccount(
          account: lastItem.account + 1,
          id: -1,
          chain: _chain,
          name: ChainHelper.chainTypeString(_chain) +
              " " +
              (lastItem.account + 2).toString()));
    }
    return unusedAccounts;
  }

  @override
  Future<tx.Transaction> getTransaction(String id) {
    // TODO: implement getTransaction
    throw UnimplementedError();
  }
}
