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
      expect(tx,
          "02000000000101bb5fee4f1d67b6be0523fd03ff62da8b912d0b73e6c9dcc83fdcf3f1c63a842d000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0218a823fc0600000017a9146015a95984366c654bbd6ab55edab391ff8d747f870000000000000000456a43446654784217a9141084ef98bacfecbc9f140496b26516ae55d79bfa870117a9141084ef98bacfecbc9f140496b26516ae55d79bfa870101000000d64efedb040000000247304402206cbc6f66b13e6c998a7c56c3599133630a679cd1c6d036e5c234ff3a390566b6022053d953c56f96a0bcc1b9cc639e3fb7b490f4eec908cd034a5ebd6eed34c82363012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });

  });

}
