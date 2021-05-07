import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    initTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
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
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    }

    test("#1 test create tx", () async {
      await initTest();
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      final tx = await wallet.createSendTransaction(1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      expect(tx.item1,
          "020000000001027183420ff39067699eac9ec3b22d9e6a5466c3bf31b50a32fa73f04e47df6ac0010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff27278e5cbc857433ffc08bdeaa7e5d563011b756715024cf20d978ec7fa05dd80000000017160014faf5b246f4ed8fe5b9e149a036404aa2c2ea451bffffffff024a2d50490600000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa87024730440220188199841f61f87aa5adc8cb6af3ea8007b31e0e0b6b29332a7461f4b5d1939b022009004c175e798983a3d4e4485fc50d20dad1830ea18549d763af964ecbe0663d012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c0247304402201e69e0415dd9a66cffb8b34b59560eaffd79448d0ec77f81f57b6410f6e7f45b02203cdd45609b93ab36d6707de719459dec98a04fade5345add12db7f2d0dcd8afa01210241e3f9c894cd6d44c6a262d442f7aaf92e41c1dd6eb118334e7c5742335c8bcc00000000");
      await destroyTest();
    });
  });

  group("#2 create 2nd tx", () {
    initTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
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

    destroyTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    }

    test("#1 create 2nd tx", () async {
      await initTest();
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      final tx = await wallet.createSendTransaction(1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      expect(tx.item1,
          "020000000001020c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f9010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f90000000017160014f5baba69ac8107ca3f47bf3a0d7afef76c5d2d4bffffffff02622950490600000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa87024830450221009eb4d352512302fb87ad37c3daf86eb60229a685d57bfc03a399c3b573b373b902203073880512df6eeba3095386eed5d7db72cc3a1099486d02aaf1bec2893beb67012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c0247304402203d0d8de2778f293bcab716d3ca8b109de508f8bc1ab9b2cf98444f8b663f9a4a022075d4c94ffb016a4f510546fdd258999050d0950243a8094e0badf07c8caa766f012103d9692afdab3120cb1b9d848de7d72c97cc2e21c00af07d0d5a98df1a4498359600000000");
      await destroyTest();
    });
  });
}
