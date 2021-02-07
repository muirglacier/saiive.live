import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';

import 'package:defichainwallet/helper/logger/LogHelper.dart';

class Wallet extends IWallet {
  Map<int, IHdWallet> _wallets = Map<int, IHdWallet>();

  int _account;
  final ChainType _chain;
  ChainNet _network;

  String _password;
  String _seed;
  ApiService _apiService;
  IWalletDatabase _walletDatabase;

  bool _isInitialized = false;

  Wallet(this._chain);

  void _isInitialzed() {
    if (!_isInitialized) {
      throw Error();
    }
  }

  @override
  Future init() async {
    _apiService = sl.get<ApiService>();
    _walletDatabase = sl.get<IWalletDatabase>();

    _password = ""; // TODO
    _seed = await sl.get<IVault>().getSeed();
    _network = await sl.get<SharedPrefsUtil>().getChainNetwork();
    _account = 0; //default account, for now only 0!

    final accounts = await _walletDatabase.getAccounts();

    for (var account in accounts) {
      final wallet = new HdWallet(_password, account, _chain, _network,
          mnemonicToSeedHex(_seed), _apiService);

      _wallets.putIfAbsent(account.account, () => wallet);
    }

    _isInitialized = true;
  }

  @override
  void setWorkingAccount(int account) {
    _isInitialzed();
    _account = account;
  }

  @override
  Future<String> getPublicKey() async {
    _isInitialzed();
    return getPublicKeyFromAccount(_account, false);
  }

  @override
  Future<String> getPublicKeyFromAccount(
      int account, bool isChangeAddress) async {
    _isInitialzed();
    assert(_wallets.containsKey(account));

    if (_wallets.containsKey(account)) {
      return await _wallets[account]
          .nextFreePublicKey(_walletDatabase, isChangeAddress);
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> syncBalance() async {
    _isInitialzed();
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
      LogHelper.instance.e("error sync balance", e);
    }
    return ret;
  }

  @override
  Future<WalletAccount> addAccount(String name, int account) {
    _isInitialzed();
    return _walletDatabase.addAccount(
        name: name, account: account, chain: _chain);
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    _isInitialzed();
    return _walletDatabase.getAccounts();
  }

  @override
  Future<List<WalletAccount>> searchAccounts() async {
    _isInitialzed();

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
  Future<String> createSendTransaction(
      int amount, String token, String to) async {
    _isInitialzed();

    final tokenBalance =
        await _walletDatabase.getAccountBalance(token);

    if (amount > tokenBalance) {
      throw Error(); //insufficent funds
    }
    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = 1000;

    final checkAmount = amount + fee;

    var curAmount = 0.0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }

    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final txHex = await HdWalletUtil.buildTransaction(
        useTxs, keys, to, amount, fee, changeAddress, _chain, _network);

    return txHex;
  }

  @override
  Future<tx.Transaction> getTransaction(String id) {
    throw UnimplementedError();
  }
}
