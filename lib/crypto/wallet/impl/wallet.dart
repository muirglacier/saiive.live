import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/from_account.dart';
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

  Future<List<String>> getPublicKeys() async {
    _isInitialzed();
    List<String> keys = [];

    for (var wallet in _wallets.values) {
      keys.addAll(await wallet.getPublicKeys());
    }

    return keys;
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

    if (token == DeFiConstants.DefiTokenSymbol) {
      await prepareUtxo(amount);
      return await _createUtxoTransaction(amount, to);
    }
    return await _createAccountTransaction(token, amount, to);
  }

  Future<String> _createAccountTransaction(
      String token, int amount, String to) async {
    if (token == DeFiConstants.DefiAccountSymbol ||
        token == DeFiConstants.DefiTokenSymbol) {
      throw new ArgumentError(
          "$token not supported for account transactions...");
    }

    final tokenBalance = await _walletDatabase.getAccountBalance(token);

    if (amount > tokenBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final tokenType = await _apiService.tokenService.getToken("DFI", token);
    final key = mnemonicToSeed(_seed);

    final accounts = await _walletDatabase.getAccountBalancesForToken(token);
    final useAccounts = List<FromAccount>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee();

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    var curAmount = 0;
    for (final tx in accounts) {
      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      inputTxs.add(await _getAuthInputsSmart(
          tx.address, tx.account, tx.isChangeAddress, tx.index));

      final keyPair = HdWalletUtil.getKeyPair(
          key,
          _account,
          tx.isChangeAddress,
          tx.index,
          ChainHelper.chainFromString(tx.chain),
          ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = tx.balance - curAmount;
        break;
      }
      curAmount += tx.balance;
    }

    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final txb = await HdWalletUtil.buildAccountToAccountTransaction(
        inputTxs,
        useAccounts,
        keys,
        tokenType.id,
        to,
        amount,
        fee,
        changeAddress,
        _chain,
        _network);

    return txb.build().toHex();
  }

  Future<tx.Transaction> _createAuthTx(
      int account, bool isChangeAddress, int index) {
    //TODO
    throw ArgumentError("NOT IMPLEMENTED RIGHT NOW!");
  }

  Future<String> _createUtxoTransaction(int amount, String to) async {
    final changeAddress = await getPublicKeyFromAccount(_account, true);
    final tokenBalance =
        await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (amount > tokenBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }
    final key = mnemonicToSeed(_seed);

    final unspentTxs = await _walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee();

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

    final txb = await HdWalletUtil.buildTransaction(
        useTxs, keys, to, amount, fee, changeAddress, _chain, _network);

    return txb.build().toHex();
  }

  Future<tx.Transaction> _getAuthInputsSmart(
      String pubKey, int account, bool isChangeAddress, int index) async {
    var authTxs =
        await _walletDatabase.getUnspentTransactionsForPubKey(pubKey, 1);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    return await _createAuthTx(account, isChangeAddress, index);
  }

  @override
  Future<tx.Transaction> getTransaction(String id) {
    throw UnimplementedError();
  }

  Future<int> getTxFee() async {
    return 1000;
  }

  Future prepareUtxo(int amount) async {
    var tokenBalance =
        await _walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == 0) {
      throw new ArgumentError(
          "Token balance must be greater than 0 to create any tx!");
    }
    // we have currently enough utxo
    if (tokenBalance > amount) {
      return;
    }

    var accountBalance = await _walletDatabase
        .getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance + tokenBalance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    final neededUtxo = amount - tokenBalance;

    final accounts = await _walletDatabase
        .getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }

    final neededAccounts = List<Account>.empty(growable: true);
    var accBalance = 0;
    for (final acc in accounts) {
      neededAccounts.add(acc);

      if ((accBalance + acc.balance) >= neededUtxo) {
        break;

        
      }
      accBalance += acc.balance;
    }
  }

  Future prepareAccount(int amount) {}
}
