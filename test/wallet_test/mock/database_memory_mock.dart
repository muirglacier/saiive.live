import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';

class MemoryDatabaseMock extends IWalletDatabase {
  List<Account> _accounts = List<Account>.empty(growable: true);
  List<WalletAccount> _walletAccounts =
      List<WalletAccount>.empty(growable: true);
  List<Transaction> _transactions = List<Transaction>.empty(growable: true);
  List<Transaction> _unspentTransactions =
      List<Transaction>.empty(growable: true);

  @override
  Future<WalletAccount> addAccount(
      {String name,
      int account,
      ChainType chain,
      bool isSelected = false}) async {
    var newAccount = WalletAccount();
    newAccount.name = name;
    newAccount.account = account;
    newAccount.id = account;
    newAccount.chain = chain;
    newAccount.selected = isSelected;

    _walletAccounts.add(newAccount);

    return newAccount;
  }

  @override
  Future addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future addUnspentTransaction(Transaction transaction) async {
    _unspentTransactions.add(transaction);
  }

  @override
  Future clearAccountBalances() async {}

  @override
  Future clearTransactions() async {
    _transactions.clear();
  }

  @override
  Future clearUnspentTransactions() async {
    _unspentTransactions.clear();
  }

  @override
  Future close() async {}

  @override
  Future destroy() async {
    _accounts.clear();
    _transactions.clear();
    _unspentTransactions.clear();
    _walletAccounts.clear();
  }

  @override
  Future<AccountBalance> getAccountBalance(String token) async {
    var balance = 0;

    if (token == DeFiConstants.DefiTokenSymbol) {
      for (var tx in _unspentTransactions) {
        balance += tx.value;
      }
    } else {
      for (var acc in _accounts) {
        if (acc.token == token) {
          balance += acc.balance;
        }
      }
    }

    return AccountBalance(balance: balance, token: token);
  }

  @override
  Future<List<Account>> getAccountBalances() async {
    return _accounts;
  }

  @override
  Future<List<WalletAccount>> getAccounts() {
    return Future.value(_walletAccounts);
  }

  @override
  Future<int> getNextFreeIndex(int account) async {
    return 0;
  }

  @override
  Future<List<AccountBalance>> getTotalBalances() {
    // TODO: implement getTotalBalances
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    return _transactions;
  }

  @override
  Future<Transaction> getTransaction(String id) async {
    for (final tx in _transactions) {
      if (tx.id == id) {
        return tx;
      }
    }

    return null;
  }

  @override
  Future<List<Transaction>> getUnspentTransactions() {
    return Future.value(_transactions);
  }

  @override
  Future<List<Transaction>> getUnspentTransactionsForPubKey(
      String pubKey, int minAmount) async {
    var ret = List<Transaction>.empty(growable: true);

    for (final tx in _unspentTransactions) {
      if (tx.address == pubKey && tx.value >= minAmount) {
        ret.add(tx);
      }
    }

    return ret;
  }

  @override
  Future open() async {}

  @override
  Future setAccountBalance(Account balance) async {
    _accounts.add(balance);
  }

  @override
  Future<WalletAccount> updateAccount(WalletAccount account) async {
    return null;
  }

  @override
  Future<Account> getAccountBalanceForPubKey(
      String pubKey, String token) async {
    for (final acc in _accounts) {
      if (acc.address == pubKey && acc.token == token) {
        return acc;
      }
    }
    return null;
  }

  @override
  Future<List<Account>> getAccountBalancesForToken(String token) async {
    var ret = List<Account>.empty(growable: true);

    for (final acc in _accounts) {
      if (acc.token == token) {
        ret.add(acc);
      }
    }
    return ret;
  }
}
