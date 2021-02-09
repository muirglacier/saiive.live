import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/crypto/chain.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    test("#0 init database...", () async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      await db.addTransaction(Transaction(
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
          value: 1000000000,
          isChangeAddress: false,
          confirmations: -1));
      await db.addTransaction(Transaction(
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
          value: 26999795496,
          isChangeAddress: false,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
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
          value: 1000000000,
          isChangeAddress: false,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
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
          isChangeAddress: false,
          address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN",
          value: 26999795496,
          confirmations: -1));
    });

    test("#1 test create tx", () async {
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      final tx = await wallet.createSendTransaction(
          1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      expect(tx,
          "020000000001027183420ff39067699eac9ec3b22d9e6a5466c3bf31b50a32fa73f04e47df6ac0010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff27278e5cbc857433ffc08bdeaa7e5d563011b756715024cf20d978ec7fa05dd80000000017160014faf5b246f4ed8fe5b9e149a036404aa2c2ea451bffffffff02402b50490600000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702473044022067acb386b138ad7ff894c5fbbe6e91e3a3e1bd153861fd244000982ff9a5e6ba02204d1061e89ede5f525583eef7846d95a98b92f5f0629388f4824da01d7a591421012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c0248304502210080d217aae754611d4ba5f577b832beabf4f78f263b9614fc941b184eee392f6802201e7041e8b2eadbe07b37d13d233432b80c2a27ec0590576e3e6f1ec1e4adef8201210241e3f9c894cd6d44c6a262d442f7aaf92e41c1dd6eb118334e7c5742335c8bcc00000000");
      debugPrint(tx);
    });
    test("#2 destroy", () async {
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    });
  });

  group("#2 create 2nd tx", () {
    test("#0 init database...", () async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      await db.addTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3d",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 1,
          mintTxId:
              "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          isChangeAddress: false,
          confirmations: -1));
      await db.addTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3b",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          isChangeAddress: true,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 26999794496,
          confirmations: -1));

      await db.addUnspentTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3d",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 1,
          mintTxId:
              "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 1000000000,
          isChangeAddress: false,
          confirmations: -1));
      await db.addUnspentTransaction(Transaction(
          id: "60157d3ddc5c117a2b26ae3b",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "f9a02e425f14f57d21a18d4fadf87447161b7db78d52b0edc08fe930a5a0960c",
          mintHeight: 192804,
          spentHeight: -2,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 26999794496,
          isChangeAddress: true,
          confirmations: -1));
    });

    test("#1 create 2nd tx", () async {
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      final tx = await wallet.createSendTransaction(
          1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      expect(tx,
          "020000000001020c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f9010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0c96a0a530e98fc0edb0528db77d1b164774f8ad4f8da1217df5145f422ea0f90000000017160014f5baba69ac8107ca3f47bf3a0d7afef76c5d2d4bffffffff02582750490600000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702473044022066ddf7ccab40fa4cde9c8a29b2af55563a09a413c6184e991eb456976a9d1bbd02207a18b55b6461e4fa5881cc6b3c90f5f7892007f851345e26d1179e2d84794da5012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c024730440220636b8585d11344b753fb958c32c67573a7ef22022ee9205b735c48e1aea0e1cb022068fe3b7e503895d34d4a53284bcb0c29255423dacdfc5dbb7e94ee0bab30225c012103d9692afdab3120cb1b9d848de7d72c97cc2e21c00af07d0d5a98df1a4498359600000000");
      debugPrint(tx);
    });

    test("#2 destroy", () async {
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    });
  });
}
