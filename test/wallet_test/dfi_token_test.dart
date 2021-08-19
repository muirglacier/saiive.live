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
      final walletAccount = WalletAccount(Uuid().v4(),
          id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, derivationPathType: DerivationPathType.BIP32, name: "acc", selected: true);
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
          "0400000000010127278e5cbc857433ffc08bdeaa7e5d563011b756715024cf20d978ec7fa05dd80000000017160014faf5b246f4ed8fe5b9e149a036404aa2c2ea451bffffffff0200ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa87009863b50d0600000017a9146015a95984366c654bbd6ab55edab391ff8d747f87000247304402202e606d6e9ed068eb23f3579f5b98d0fbe2ed1754b618c177c9ffb74926a9489f022042b1f1eb0e9f73d052eb22916204244630b65c0ed9ccc452a82886b24301bcbe01210241e3f9c894cd6d44c6a262d442f7aaf92e41c1dd6eb118334e7c5742335c8bcc00000000");

      await destroyTest();
    });
  });

  group("#2 create 2nd tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAccount = WalletAccount(Uuid().v4(),
          id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, derivationPathType: DerivationPathType.BIP32, name: "acc", selected: true);
      await db.addOrUpdateAccount(walletAccount);

      await db.addTransaction(
          Transaction(
              id: "60157d3ddc5c117a2b26ae3d",
              chain: "DFI",
              network: "testnet",
              mintIndex: 1,
              mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
              mintHeight: 192804,
              spentHeight: -2,
              address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
              value: 1000000000,
              confirmations: -1),
          walletAccount);
      await db.addTransaction(
          Transaction(
              id: "60157d3ddc5c117a2b26ae3b",
              chain: "DFI",
              network: "testnet",
              mintIndex: 0,
              mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
              mintHeight: 192804,
              spentHeight: -2,
              address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
              value: 26999794496,
              confirmations: -1),
          walletAccount);

      await db.addUnspentTransaction(
          Transaction(
              id: "60157d3ddc5c117a2b26ae3d",
              chain: "DFI",
              network: "testnet",
              mintIndex: 1,
              mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
              mintHeight: 192804,
              spentHeight: -2,
              address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
              value: 1000000000,
              confirmations: -1),
          walletAccount);
      await db.addUnspentTransaction(
          Transaction(
              id: "60157d3ddc5c117a2b26ae3b",
              chain: "DFI",
              network: "testnet",
              mintIndex: 0,
              mintTxId: "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
              mintHeight: 192804,
              spentHeight: -2,
              address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
              value: 26999794496,
              confirmations: -1),
          walletAccount);

      final dfiToken =
          Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 500 * 100000000, raw: "@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken, walletAccount);
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
          "040000000001010c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f90000000017160014f5baba69ac8107ca3f47bf3a0d7afef76c5d2d4bffffffff0200ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8700b05fb50d0600000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b87000247304402201a34e6a33a62f80a40c6ec25dd09ff58822e39aa8873628e5c6f8fa33c2b43a802203e7acf6b537d353eca93d5c708be0b7436efb166b509ffd564a0a6165773e22a012103d9692afdab3120cb1b9d848de7d72c97cc2e21c00af07d0d5a98df1a4498359600000000");

      await destroyTest();
    });
  });
}
