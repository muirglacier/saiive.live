import 'package:defichainwallet/crypto/database/wallet_database_factory.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain);
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

      await db.setAccountBalance(
          Account(token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 49418047703, chain: "DFI", network: "testnet"));
      await db.setAccountBalance(Account(token: "BTC", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 22598748024, chain: "DFI", network: "testnet"));
      await db.setAccountBalance(Account(token: "BTC", address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", balance: 12598748024, chain: "DFI", network: "testnet"));
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create swao tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.addPoolLiquidity("DFI", 100000000, "BTC", 8160367226, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      final txHex = tx;

      expect(txHex,
          "02000000000102cce6fe43f14f092a777a74dbea0c6745beab0fc5520ff338354bf0753f45fa2c020000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffffca14022e34d5b9fedf25f6aa5c68cc340f8b9a7fdf496b88462d59912be0b41b0100000017160014cba72e413b025786aaa742e44c6b28031c6aa348ffffffff0200000000000000006b6a4c68446654786c0217a9141084ef98bacfecbc9f140496b26516ae55d79bfa87010000000000e1f5050000000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8701010000007a5265e60100000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa878521f57b0f00000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702483045022100d2627e9bcc92791813327109408883908be834212aac18b0c7c30b743f34781b0220207a1c5491a49efd776ed3766d03fa01491d31c35a02ac5d5432692f395e7d5b012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c02473044022023ec1b3951baafce17a4241b5d6d24431865022f8f54fff3c0ad30047bbda925022003515d0600debf4d0a1a5d9c5375a16d7554d3bea6bb7aea398572d67e103290012102db81fb45bd3f1598e3d0bfaafc7fb96c2c693c88e03b14e26b9928abc780f33100000000");

      await destoryTest();
    });
  });
}
