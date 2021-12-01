import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import '../mock/transaction_service_mock.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

      final walletAccount = WalletAccount(Uuid().v4(),
          id: 0,
          chain: ChainType.DeFiChain,
          account: 0,
          walletAccountType: WalletAccountType.HdAccount,
          derivationPathType: PathDerivationType.FullNodeWallet,
          name: "acc",
          selected: true);
      await db.addOrUpdateAccount(walletAccount);

      final tx = Transaction(
          id: "6026c7e3779edc3b788b6928",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "beabf8b02ad791a74b4544ffd8c44cb6c8cdb605ecd3c92b23a2d2b8f6987d95",
          mintHeight: 218296,
          spentHeight: -2,
          address: "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4",
          value: 66866570269,
          confirmations: -1);
      await db.addTransaction(tx, walletAccount);
      await db.addUnspentTransaction(tx, walletAccount);

      final tx2 = Transaction(
          id: "602ab71b779edc3b780ff2da",
          chain: "DFI",
          network: "testnet",
          mintIndex: 2,
          mintTxId: "c087581066fd0aa95a6f65ea31ea94a807061182c207dc87dbec29f23c7518de",
          mintHeight: 227341,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 200000,
          confirmations: -1);
      await db.addTransaction(tx2, walletAccount);
      await db.addUnspentTransaction(tx2, walletAccount);

      final dfiToken = Account(
          token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: tx.value + tx2.value, raw: "@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiToken, walletAccount);

      final dfiAccount = Account(
          token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 40995318784, raw: "40995318784@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiAccount, walletAccount);
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
      final tx = await wallet.prepareAccountToUtxosTransactions("tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4", 600 * 100000000);
      expect(tx, null);
      await destoryTest();
    });

    test("create accountToUtxos tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final txController = sl.get<TransactionServiceMock>();
      await wallet.prepareAccountToUtxosTransactions("toMR4jje52shBy5Mi5wEGWvAETLBCsZprw", 800 * 100000000);
      expect(txController.lastTx,
          "04000000000101de18753cf229ecdb87dc07c282110607a894ea31ea656f5aa90afd66105887c0020000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0300000000000000002d6a2b446654786217a9141084ef98bacfecbc9f140496b26516ae55d79bfa870100000000a32ecd0e030000000200a0fd02000000000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8700a32ecd0e0300000017a914bb7642fd3a9945fd75aff551d9a740768ac7ca7b8700024730440220711dd9cbdf768701ce9f7be4864f3a653228c90d0457902864f9ba75626adc0a022066f73bff3dc3de6699d7b7d7158de5dfab2cd4d4acb61bed0a0581be5f7fe5ef012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });
  });
}
