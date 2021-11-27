import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/errors/RegenerateWalletAddressError.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx with invalid change addr", () {
    Future<WalletAccount> initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAccount = WalletAccount(Uuid().v4(),
          id: 0,
          chain: ChainType.DeFiChain,
          account: 0,
          walletAccountType: WalletAccountType.HdAccount,
          derivationPathType: PathDerivationType.FullNodeWallet,
          name: "acc",
          selected: true);
      await db.addOrUpdateAccount(walletAccount);

      await db.addTransaction(
          Transaction(
              id: "601496faf1963a034ec57842",
              chain: "DFI",
              network: "testnet",
              mintIndex: 1,
              mintTxId: "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
              mintHeight: 192706,
              spentHeight: -2,
              address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
              value: 1000000000,
              confirmations: -1),
          walletAccount);
      await db.addTransaction(
          Transaction(
              id: "60156e30dc5c117a2b211187",
              chain: "DFI",
              network: "testnet",
              mintIndex: 0,
              mintTxId: "d85da07fec78d920cf24507156b71130565d7eaade8bc0ff337485bc5c8e2727",
              mintHeight: 192738,
              spentHeight: -2,
              address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
              value: 26999795496,
              confirmations: -1),
          walletAccount);
      await db.addUnspentTransaction(
          Transaction(
              id: "601496faf1963a034ec57842",
              chain: "DFI",
              network: "testnet",
              mintIndex: 1,
              mintTxId: "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
              mintHeight: 192706,
              spentHeight: -2,
              address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
              value: 1000000000,
              confirmations: -1),
          walletAccount);
      await db.addUnspentTransaction(
          Transaction(
              id: "60156e30dc5c117a2b211187",
              chain: "DFI",
              network: "testnet",
              mintIndex: 0,
              mintTxId: "d85da07fec78d920cf24507156b71130565d7eaade8bc0ff337485bc5c8e2727",
              mintHeight: 192738,
              spentHeight: -2,
              address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
              value: 26999795496,
              confirmations: -1),
          walletAccount);

      final dfiToken =
          Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 500 * 100000000, raw: "@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken, walletAccount);

      return walletAccount;
    }

    Future destroyTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 change address not spentable", () async {
      await initTest();
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      expect(() async {
        await wallet.checkIfWeCanSpendTheChangeAddress("tXdQc5VmwMCgJS9b2tckvcQxKBo9wYdXAB");
      }, throwsA(isA<RegenerateWalletAddressError>()));

      await destroyTest();
    });

    test("#2 change address not spentable", () async {
      var acc = await initTest();
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAddress = WalletAddress(
          accountId: acc.uniqueId,
          index: 0,
          chain: ChainType.DeFiChain,
          account: 1,
          isChangeAddress: true,
          publicKey: "tXdQc5VmwMCgJS9b2tckvcQxKBo9wYdXAB",
          network: ChainNet.Testnet,
          addressType: AddressType.P2SHSegwit);
      await db.addAddress(walletAddress);

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      expect(() async {
        await wallet.checkIfWeCanSpendTheChangeAddress("tXdQc5VmwMCgJS9b2tckvcQxKBo9wYdXAB");
      }, throwsA(isA<RegenerateWalletAddressError>()));

      await destroyTest();
    });
  });
}
