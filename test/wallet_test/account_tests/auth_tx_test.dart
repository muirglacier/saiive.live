import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/crypto/chain.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup(
      "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      final tx = Transaction(
          id: "6024016c779edc3b78c36454",
          chain: "DFI",
          index: 0,
          account: 0,
          network: "testnet",
          mintIndex: 0,
          mintTxId:
              "7846a2232936665b9eb40c1130239e65467933196d7b307add67b9fb3fd5cc98",
          mintHeight: 215694,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 16453181891,
          isChangeAddress: false,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);


      final btcAccount = Account(
          token: "BTC",
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 19205428099,
          raw: "192.05428099@BTC",
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

    test("create auth tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx =
          await wallet.createAuthTx("tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(tx,
          "0200000000010198ccd53ffbb967dd7a307b6d19337946659e2330110cb49e5b66362923a24678000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff030000000000000000076a0544665478419b90acd40300000017a9146015a95984366c654bbd6ab55edab391ff8d747f87400d03000000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702473044022048bbc1adcf69c3b7d7c6b2630ea13f00ffe8ee05fcefff5f7f2342c6a92376ee02202cdb7fe54d4653f34a96d5e4f363c9bc42b26d2787fadf967ffebbbb421a025c012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });
  });
}
