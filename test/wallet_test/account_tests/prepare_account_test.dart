import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import '../mock/transaction_service_mock.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      await db.addAccount(name: "acc", account: 0, chain: ChainType.DeFiChain);
      final tx = Transaction(
          id: "6026c7e3779edc3b788b6928",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "520be057c9cf6846cc9073a7f2690e549523a1e16c5438d6c4bc6a24a6c5cdc4",
          mintHeight: 218296,
          spentHeight: -2,
          address: "toMR4jje52shBy5Mi5wEGWvAETLBCsZprw",
          value: 66904421465,
          confirmations: -1);
      await db.addTransaction(tx);
      await db.addUnspentTransaction(tx);

      final dfiAccount = Account(
          token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 24262150804, raw: "242.62150804@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiAccount);
      final dfiToken = Account(
          token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 100000000, raw: "100000000@\$DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("has enough acc", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final txController = sl.get<TransactionServiceMock>();
      final tx = await wallet.prepareUtxoToAccountTransaction(240 * 100000000);
      expect(tx, 240 * 100000000);
      expect(txController.lastTx, null);
      await destoryTest();
    });

    test("create utxosToAccount tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      await wallet.prepareUtxoToAccountTransaction(243 * 100000000);
      final txController = sl.get<TransactionServiceMock>();
      expect(txController.lastTx,
          "02000000000101c4cdc5a6246abcc4d638546ce1a12395540e69f2a77390cc4668cfc957e00b520100000017160014cba72e413b025786aaa742e44c6b28031c6aa348ffffffff0224944102000000002d6a2b44665478550117a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8701000000002494410200000000edd28e910f00000017a9146015a95984366c654bbd6ab55edab391ff8d747f870247304402204a1ca5da2e55974f12b95c81bc58885e94b8d2981bad547443030587f6a45ce602207b7ab0d6888be7bc542b76b5017bcc4dba80018b94fa1fc78bb15f8ad0062330012102db81fb45bd3f1598e3d0bfaafc7fb96c2c693c88e03b14e26b9928abc780f33100000000");
      await destoryTest();
    });
  });
}
