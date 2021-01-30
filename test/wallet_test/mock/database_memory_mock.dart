import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';

class MemoryDatabaseMock extends IWalletDatabase {
  @override
  Future<WalletAccount> addAccount(
      {String name, int account, ChainType chain, bool isSelected = false}) {
    // TODO: implement addAccount
    throw UnimplementedError();
  }

  @override
  Future addTransaction(Transaction transaction) async {}

  @override
  Future addUnspentTransaction(Transaction transaction) async {}

  @override
  Future clearAccountBalances() async {}

  @override
  Future clearTransactions() async {}

  @override
  Future clearUnspentTransactions() async {}

  @override
  Future close() async {}

  @override
  Future destroy() async {}

  @override
  Future<double> getAccountBalance(String token) async {
    return 279;
  }

  @override
  Future<List<Account>> getAccountBalances() async {
    return [Account(address: "", balance: 279.99795896, token: "\$DFI")];
  }

  @override
  Future<List<WalletAccount>> getAccounts() async {
    return [
      WalletAccount(
          account: 0,
          balance: "269.99795496",
          chain: ChainType.DeFiChain,
          id: 1,
          isChangeAddress: false,
          publicKey: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN"),
      WalletAccount(
          account: 0,
          balance: "10",
          chain: ChainType.DeFiChain,
          id: 0,
          isChangeAddress: false,
          publicKey: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv")
    ];
  }

  @override
  Future<int> getNextFreeIndex(int account) async {
    return 0;
  }

  @override
  Future<Map<String, double>> getTotalBalances() {
    // TODO: implement getTotalBalances
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getTransactions() {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getUnspentTransactions() async {
    return [
      Transaction(
          id: "601496faf1963a034ec57842",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 1,
          mintTxId:
              "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
          mintHeight: 192706,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 10,
          confirmations: -1),
      Transaction(
          id: "60156e30dc5c117a2b211187",
          chain: "DFI",
          index: 1,
          account: 0,
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "d85da07fec78d920cf24507156b71130565d7eaade8bc0ff337485bc5c8e2727",
          mintHeight: 192738,
          spentHeight: -2,
          address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
          value: 269.99795496,
          confirmations: -1)
    ];
  }

  @override
  Future open() async {}

  @override
  Future setAccountBalance(Account balance) async {}

  @override
  Future<WalletAccount> updateAccount(WalletAccount account) async {}
}
