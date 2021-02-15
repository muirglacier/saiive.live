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
          id: "6026c7e3779edc3b788b6928",
          chain: "DFI",
          index: 1,
          account: 0,
          network: "testnet",
          mintIndex: 1,
          mintTxId:
              "520be057c9cf6846cc9073a7f2690e549523a1e16c5438d6c4bc6a24a6c5cdc4",
          mintHeight: 218296,
          spentHeight: -2,
          address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw",
          value: 66904421465,
          isChangeAddress: true,
          confirmations: -1);
      await db.addTransaction(tx);


      final dfiAccount = Account(
          token: DeFiConstants.DefiAccountSymbol,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 24262150804,
          raw: "242.62150804@DFI",
          index: 0,
          account: 0,
          isChangeAddress: false,
          chain: "DFI",
          network: "testnet");

      await db.setAccountBalance(dfiAccount);
      final dfiToken = Account(
          token: DeFiConstants.DefiTokenSymbol,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          balance: 100000000,
          raw: "100000000@\$DFI",
          index: 0,
          account: 0,
          isChangeAddress: false,
          chain: "DFI",
          network: "testnet");

      await db.setAccountBalance(dfiToken);
    }

    Future destoryTest() async {
      final db = sl.get<IWalletDatabase>();
      await db.destroy();
    }

    test("has enough acc", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.prepareUtxoToAccountTransaction(240 * 100000000);
      expect(tx, null);
      await destoryTest();
    });

    test("create utxosToAccount tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.prepareUtxoToAccountTransaction(243 * 100000000);
      expect(tx.item1,
          "02000000000101c4cdc5a6246abcc4d638546ce1a12395540e69f2a77390cc4668cfc957e00b520100000017160014cba72e413b025786aaa742e44c6b28031c6aa348ffffffff02548c4102000000002d6a2b44665478550117a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b870100000000548c4102000000001de48e910f00000017a9146015a95984366c654bbd6ab55edab391ff8d747f870247304402204fc0c2bd97cfa1341f5dab9c2e84cc9a0d8a4590588adc251f3da659ade0ae4302201df553e4d2017d48c81a135beeb38c9fb4eea7cf31ef5afb77d547515bc1f98c012102db81fb45bd3f1598e3d0bfaafc7fb96c2c693c88e03b14e26b9928abc780f33100000000");
      await destoryTest();
    });
  });
}
