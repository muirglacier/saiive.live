import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'mock/transaction_service_mock.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);
      final walletAccount = WalletAccount(uniqueId: Uuid().v4(), id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, name: "acc");
      await db.addOrUpdateAccount(walletAccount);

      await db.addTransaction(Transaction(
          id: "601496faf1963a034ec57842",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
          mintHeight: 192706,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          confirmations: -1));
      await db.addTransaction(Transaction(
          id: "60156e30dc5c117a2b211187",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "d85da07fec78d920cf24507156b71130565d7eaade8bc0ff337485bc5c8e2727",
          mintHeight: 192738,
          spentHeight: -2,
          address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
          value: 26999795496,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
          id: "601496faf1963a034ec57842",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
          mintHeight: 192706,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
          id: "60156e30dc5c117a2b211187",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "d85da07fec78d920cf24507156b71130565d7eaade8bc0ff337485bc5c8e2727",
          mintHeight: 192738,
          spentHeight: -2,
          address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
          value: 26999795496,
          confirmations: -1));

      final dfiToken =
          Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 500 * 100000000, raw: "@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken);
    }

    Future destroyTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 test create tx", () async {
      await initTest();
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      final txController = sl.get<TransactionServiceMock>();
      await wallet.createSendTransaction(1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(txController.lastTx,
          "0200000000010127278e5cbc857433ffc08bdeaa7e5d563011b756715024cf20d978ec7fa05dd80000000017160014faf5b246f4ed8fe5b9e149a036404aa2c2ea451bffffffff029863b50d0600000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702483045022100bf7139caa147efe7174a0805ee357973948127719a43e80821b5b0625083238002201164a3d5fa140875805676773bdedc238cceb5b7ff8d7b3d0175dcbf42a5922001210241e3f9c894cd6d44c6a262d442f7aaf92e41c1dd6eb118334e7c5742335c8bcc00000000");

      await destroyTest();
    });
  });

  group("#2 create 2nd tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAccount = WalletAccount(uniqueId: Uuid().v4(), id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, name: "acc");
      await db.addOrUpdateAccount(walletAccount);

      await db.addTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3d",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          confirmations: -1));
      await db.addTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3b",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 26999794496,
          confirmations: -1));

      await db.addUnspentTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3d",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3b",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 26999794496,
          confirmations: -1));

      final dfiToken =
          Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 500 * 100000000, raw: "@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken);
    }

    Future destroyTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create 2nd tx", () async {
      await initTest();
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      await wallet.createSendTransaction(1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      final txController = sl.get<TransactionServiceMock>();
      expect(txController.lastTx,
          "020000000001010c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f90000000017160014f5baba69ac8107ca3f47bf3a0d7afef76c5d2d4bffffffff02b05fb50d0600000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870247304402206b2fccb1d70165f73a7c2499c25d5f2c2184cf91d9dc4ee1b0edf9c86b1e78ca0220563b0e5662ab08f341a3dfa73848154d874f4e760a357ef6b410d8da38df202c012103d9692afdab3120cb1b9d848de7d72c97cc2e21c00af07d0d5a98df1a4498359600000000");

      await destroyTest();
    });
  });
}
