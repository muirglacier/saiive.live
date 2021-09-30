import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:uuid/uuid.dart';

class MemoryDatabaseMock extends IWalletDatabase {
  List<Account> _accounts = List<Account>.empty(growable: true);
  List<WalletAccount> _walletAccounts = List<WalletAccount>.empty(growable: true);
  List<Transaction> _transactions = List<Transaction>.empty(growable: true);
  List<Transaction> _unspentTransactions = List<Transaction>.empty(growable: true);

  List<WalletAddress> _addresses = List<WalletAddress>.empty(growable: true);

  bool isLocked() {
    return false;
  }

  @override
  Future<WalletAccount> addAccount({String name, int account, ChainType chain, PathDerivationType derivationPathType, bool isSelected = false}) async {
    var newAccount = WalletAccount(Uuid().v4(),
        name: name, account: account, id: account, chain: chain, selected: isSelected, walletAccountType: WalletAccountType.HdAccount, derivationPathType: derivationPathType);

    _walletAccounts.add(newAccount);

    return newAccount;
  }

  @override
  Future<WalletAccount> addOrUpdateAccount(WalletAccount walletAccount) async {
    await Future.delayed(Duration(microseconds: 1));

    for (final acc in _walletAccounts) {
      if (acc.uniqueId == walletAccount.uniqueId) {
        acc.name = walletAccount.name;
        return acc;
      }
    }
    _walletAccounts.add(walletAccount);
    return walletAccount;
  }

  @override
  Future addTransaction(Transaction transaction, WalletAccount walletAccount) async {
    _transactions.add(transaction);
  }

  @override
  Future addUnspentTransaction(Transaction transaction, WalletAccount walletAccount) async {
    var txAlreadyInList = false;

    for (final tx in _unspentTransactions) {
      if (tx.id == transaction.id) {
        txAlreadyInList = true;
        break;
      }
    }
    if (!txAlreadyInList) {
      _unspentTransactions.add(transaction);
    }
  }

  @override
  Future clearAccountBalances(WalletAccount walletAccount) async {}

  @override
  Future clearTransactions(WalletAccount walletAccount) async {
    _transactions.clear();
  }

  @override
  Future clearUnspentTransactions(WalletAccount walletAccount) async {
    _unspentTransactions.clear();
  }

  @override
  Future removeUnspentTransactions(List<Transaction> mintIds) async {}

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
  Future<AccountBalance> getAccountBalance(String token, {List<String> excludeAddresses, bool spentable = true}) async {
    if (token == DeFiConstants.DefiTokenSymbol) {
      final unspentTx = await getUnspentTransactions(spentable: spentable);
      var amount = 0;

      for (final unspent in unspentTx) {
        amount += unspent.value;
      }

      return new AccountBalance(balance: amount, token: token, chain: ChainType.DeFiChain);
    }
    var balance = 0;
    _accounts.sort((a, b) => b.balance.compareTo(a.balance));

    for (var acc in _accounts) {
      if (acc.token == token) {
        balance += acc.balance;
      }
    }

    return AccountBalance(balance: balance, token: token, chain: ChainType.DeFiChain);
  }

  @override
  Future<List<Account>> getAccountBalances(WalletAccount acc) async {
    return _accounts;
  }

  @override
  Future<WalletAccount> getAccount(String uniqueId) async {
    return _walletAccounts.firstWhere((element) => element.uniqueId == uniqueId);
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
  // ignore: override_on_non_overriding_member
  Future<List<AccountBalance>> getTotalBalances({bool spentable = true}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getTransactions(WalletAccount acc) async {
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
  Future<List<Transaction>> getUnspentTransactions({bool spentable = true}) {
    _transactions.sort((a, b) => b.valueRaw.compareTo(a.valueRaw));
    return Future.value(_transactions);
  }

  @override
  Future<List<Transaction>> getUnspentTransactionsForPubKey(String pubKey, int minAmount) async {
    var ret = List<Transaction>.empty(growable: true);

    _unspentTransactions.sort((a, b) => a.valueRaw.compareTo(b.valueRaw));
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
  Future setAccountBalance(Account balance, WalletAccount acc) async {
    _accounts.add(balance);
  }

  @override
  Future<Account> getAccountBalanceForPubKey(String pubKey, String token) async {
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

  @override
  Future<WalletAddress> addAddress(WalletAddress account) async {
    _addresses.add(account);
    return account;
  }

  @override
  Future<bool> addressExists(int account, bool isChangeAddress, int index, AddressType addressType) async {
    for (final address in _addresses) {
      if (address.account == account && address.isChangeAddress == isChangeAddress && address.index == index && address.addressType == addressType) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<WalletAddress> getWalletAddress(String pubKey) async {
    for (final address in _addresses) {
      if (address.publicKey == pubKey) {
        return address;
      }
    }
    return null;
  }

  @override
  Future<List<WalletAddress>> getWalletAllAddresses(WalletAccount account) {
    var ret = _addresses.where((element) => element.accountId == account.uniqueId).toList();
    return Future.value(ret);
  }

  @override
  Future<List<WalletAddress>> getWalletAddressesById(String uniqueId) {
    var ret = _addresses.where((element) => element.accountId == uniqueId).toList();
    return Future.value(ret);
  }

  @override
  Future<bool> isOwnAddress(String pubKey) async {
    for (final address in _addresses) {
      if (address.publicKey == pubKey) {
        return true;
      }
    }
    return false;
  }

  @override
  int getAddressCreationCount() {
    return 20;
  }

  @override
  Future<WalletAddress> getWalletAddressById(int account, bool isChangeAddress, int index, AddressType addressType) async {
    for (final address in _addresses) {
      if (address.account == account && address.isChangeAddress == isChangeAddress && address.index == index && address.addressType == addressType) {
        return address;
      }
    }
    return null;
  }

  @override
  Future<bool> addressAlreadyUsed(String address) async {
    for (final acc in _transactions) {
      if (acc.address == address) {
        return true;
      }
    }

    return false;
  }

  @override
  Future removeAccount(WalletAccount walletAccount) {
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactions;
  }
}
