import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
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
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "2d843ac6f1f3dc3fc8dcc9e6730b2d918bda62ff03fd2305beb6671d4fee5fbb",
          mintHeight: 214903,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 30000000000,
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

      final dfiAccount = Account(
          token: "\$DFI",
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 30000000000,
          raw: "300@BTC",
          index: 0,
          account: 0,
          isChangeAddress: false,
          chain: "DFI",
          network: "testnet");

      await db.setAccountBalance(dfiAccount);
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
              500 * 100000000, "BTC", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv"),
          throwsA(isA<ArgumentError>()));
      await destoryTest();
    });

    test("#4 create bitcoin accountToAccount tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createSendTransaction(
          1 * 100000000, "BTC", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(tx.item1,
          "02000000000101bb5fee4f1d67b6be0523fd03ff62da8b912d0b73e6c9dcc83fdcf3f1c63a842d000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff020000000000000000456a43446654784217a9141084ef98bacfecbc9f140496b26516ae55d79bfa870117a9141084ef98bacfecbc9f140496b26516ae55d79bfa87010100000000e1f5050000000048a023fc0600000017a9146015a95984366c654bbd6ab55edab391ff8d747f87024730440220517ee8aff9f7f8b3cfa5ccef85a9a2118d93c7839fe9a17e1a81b17e9175e10302201ae90709694f8174080f43349425285a1d910a1db1899d4206bc739b0abe1820012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });
  });
}
