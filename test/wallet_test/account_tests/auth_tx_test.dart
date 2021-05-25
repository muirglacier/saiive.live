import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/wallet/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      final tx = Transaction(
          id: "6024016c779edc3b78c36454",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "7846a2232936665b9eb40c1130239e65467933196d7b307add67b9fb3fd5cc98",
          mintHeight: 215694,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 16453181891,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);

      final btcAccount = Account(token: "BTC", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 19205428099, raw: "192.05428099@BTC", chain: "DFI", network: "testnet");

      await db.setAccountBalance(btcAccount);

      final dfiAccount = Account(token: "\$DFI", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 16453181891, raw: "16453181891@\$DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiAccount);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("create auth tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createAuthTx("tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(tx.item1,
          "0200000000010198ccd53ffbb967dd7a307b6d19337946659e2330110cb49e5b66362923a24678000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff030000000000000000076a0544665478415993acd40300000017a9146015a95984366c654bbd6ab55edab391ff8d747f87400d03000000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870247304402201f51d7f89487d5a04e1bef34a20e83da5cca96f0952a90764e26aa3ef049455802201e8116879543923455c60665676bb58ebbe80251e3072be43542e211b2111061012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });
  });
}
