import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAccount =
          WalletAccount(uniqueId: Uuid().v4(), id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, name: "acc", selected: true);
      await db.addOrUpdateAccount(walletAccount);

      final tx = Transaction(
          id: "6026c7e3779edc3b788b6928",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "5c1e5a7b92ca04ab8497f1f9f9c9242dd1845934faa534ff470473d65b4f303a",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 99999500,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);

      final tx2 = Transaction(
          id: "6025801b779edc3b78b9386e",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "520be057c9cf6846cc9073a7f2690e549523a1e16c5438d6c4bc6a24a6c5cdc4",
          mintHeight: 220440,
          spentHeight: -2,
          address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw",
          value: 66904421465,
          confirmations: -1);
      await db.addTransaction(tx2);
      await db.addUnspentTransaction(tx2);

      await db.setAccountBalance(
          Account(token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 26735666535, chain: "DFI", network: "testnet"));

      await db.setAccountBalance(Account(token: "BTC", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 20773327806, chain: "DFI", network: "testnet"));

      await db
          .setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 100000000, chain: "DFI", network: "testnet"));

      await db.setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: "tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN", balance: 200000, chain: "DFI", network: "testnet"));

      await db.setAccountBalance(Account(token: "BTC", address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", balance: 942767, chain: "DFI", network: "testnet"));
      await db
          .setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", balance: 66905804465, chain: "DFI", network: "testnet"));
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create swap tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createSwap("DFI", 1, "BTC", "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", 12627393020, 3);
      final txHex = tx.item1;

      expect(txHex,
          "02000000000102c4cdc5a6246abcc4d638546ce1a12395540e69f2a77390cc4668cfc957e00b520100000017160014cba72e413b025786aaa742e44c6b28031c6aa348ffffffff3a304f5bd6730447ff34a5fa345984d12d24c9f9f9f19784ab04ca927b5a1e5c010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff030000000000000000526a4c4f446654787317a9141084ef98bacfecbc9f140496b26516ae55d79bfa8700010000000000000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8701fcb9a6f0020000000300000000000000b15dd0930f00000017a9146015a95984366c654bbd6ab55edab391ff8d747f870cdff5050000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870247304402207de973e11e8722577a855eaad9fc71ac716e9a56f547aaeeb5995949298df099022048241c52b6b92f788c7460ecb5ca92ee91dff56c69a35a79b24a7466bf4909ec012102db81fb45bd3f1598e3d0bfaafc7fb96c2c693c88e03b14e26b9928abc780f3310248304502210095b47ade97a8b33a0e07980edfa741292e3d7bf9dceb67acf5aaf5cc5a5acef002201dd30306eb8ceed9f5ff3309cdd1a94552ec720561f59a5783ba27918ab244bd012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");

      await destoryTest();
    });
  });
}
