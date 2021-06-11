import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      final tx = Transaction(
          id: "603148cfb47e4ea74f55d98d",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "eee5c6133beca6e2b78412afea7616a85f1e717cd07d87dd6151797858e8fedf",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 99999202,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);

      final tx2 = Transaction(
          id: "6025801b779edc3b78b9386e",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "1bb4e02b91592d46886b49df7f9a8b0f34cc685caaf625dffeb9d5342e0214ca",
          mintHeight: 220440,
          spentHeight: -2,
          address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw",
          value: 66404174909,
          confirmations: -1);
      await db.addTransaction(tx2);
      await db.addUnspentTransaction(tx2);
      final tx4 = Transaction(
          id: "6033f00d701ca47b8616476f",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "c98b51e57e1886876b85b1f144c4c55fedc44a0007f1ac08f07c2533518035eb",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 100000000,
          confirmations: -1);
      await db.addTransaction(tx4);
      await db.addUnspentTransaction(tx4);

      final tx3 = Transaction(
          id: "6025801b779edc3b78b9386e",
          chain: "DFI",
          network: "testnet",
          mintIndex: 2,
          mintTxId: "2cfa453f75f04b3538f30f52c50fabbe45670ceadb747a772a094ff143fee6cc",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 100000000,
          confirmations: -1);
      await db.addTransaction(tx3);
      await db.addUnspentTransaction(tx3);

      await db.setAccountBalance(
          Account(token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 49418047703, chain: "DFI", network: "testnet"));
      await db.setAccountBalance(Account(token: "BTC", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 22598748024, chain: "DFI", network: "testnet"));
      await db.setAccountBalance(Account(token: "BTC", address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", balance: 12598748024, chain: "DFI", network: "testnet"));
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create add lm tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.addPoolLiquidity("DFI", 100000000, "BTC", 8160367226, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      final txHex = tx;

      expect(txHex,
          "02000000000101eb35805133257cf008acf107004ac4ed5fc5c444f1b1856b8786187ee5518bc9010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0200000000000000006b6a4c68446654786c0217a9141084ef98bacfecbc9f140496b26516ae55d79bfa87010000000000e1f5050000000017a9146015a95984366c654bbd6ab55edab391ff8d747f8701010000007a5265e60100000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8748d5f5050000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870247304402207d7e4b5fb82a1189c0e732ba3b62e822a368fa23ac18185572a55bc567ceb8140220702b666998958c2f5a8fce091a11122476f810a60a3fd8d50855e81a4b11af2e012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");

      await destoryTest();
    });
  });
}
