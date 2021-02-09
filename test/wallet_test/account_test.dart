import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup(
      "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      final tx = Transaction(
          id: "6022346c779edc3b789bc5b9",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "2d843ac6f1f3dc3fc8dcc9e6730b2d918bda62ff03fd2305beb6671d4fee5fbb",
          mintHeight: 214903,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 30000000000,
          isChangeAddress: false,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);

      final account = Account(
          token: DeFiConstants.DefiAccountSymbol,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 17447697269,
          raw: "174.47697269@DFI",
          index: 0,
          account: 0,
          isChangeAddress: false,
          chain: "DFI",
          network: "testnet");

      await db.setAccountBalance(account);

      final btcAccount = Account(
          token: "BTC",
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 20870745814,
          raw: "208.70745814@BTC",
          index: 0,
          account: 0,
          isChangeAddress: false,
          chain: "DFI",
          network: "testnet");

      await db.setAccountBalance(btcAccount);
    }

    Future destoryTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    }

    test("#1 test invalid utxo and account for DFI", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      expect(
          () => wallet.createSendTransaction(
              500 * 100000000,
              DeFiConstants.DefiTokenSymbol,
              "tgoVbmjxpgMHzj22y6PUPRcr7WxasGAx3n"),
          throwsA(isA<ArgumentError>()));

      await destoryTest();
    });
    test("#2 create tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createSendTransaction(1 * 100000000,
          DeFiConstants.DefiTokenSymbol, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      await destoryTest();
    });

    test("#3 create btc tx - fail", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      expect(
          () => wallet.createSendTransaction(
              500 * 100000000,
              "BTC",
              "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv"),
          throwsA(isA<ArgumentError>()));
      await destoryTest();
    });

    test("#4 create bitcoin accountToAccount tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createSendTransaction(
          1 * 100000000, "BTC", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      await destoryTest();
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

      final tx = await wallet.createSendTransaction(1000000000,
          DeFiConstants.DefiTokenSymbol, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

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
