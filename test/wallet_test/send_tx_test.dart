import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'mock/transaction_service_mock.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create send tx", () {
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
          id: "8321c8c7168ad3c5c17da1a3d6b431f3ec1b0c1398531286a3d02806c076ed6200000001",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "8321c8c7168ad3c5c17da1a3d6b431f3ec1b0c1398531286a3d02806c076ed62",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: (0.9 * 100000000).round(),
          confirmations: -1);

      final tx2 = Transaction(
          id: "11181b88b6cb06a60acdc19c62f7e7f734f900cf9a6db1c19b209f6c9a1316c6",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "11181b88b6cb06a60acdc19c62f7e7f734f900cf9a6db1c19b209f6c9a1316c6",
          mintHeight: 220440,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 10003100,
          confirmations: -1);
      await db.addTransaction(tx2, walletAccount);
      await db.addUnspentTransaction(tx2, walletAccount);
      await db.addTransaction(tx, walletAccount);
      await db.addUnspentTransaction(tx, walletAccount);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create send tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      await wallet.createSendTransaction(100000000, DeFiConstants.DefiTokenSymbol, "73vgDShNDrJo9QZUDvWH3ZH39nyMa99MS1");
      final txController = sl.get<TransactionServiceMock>();
      expect(txController.lastTx,
          "0400000000010262ed76c00628d0a386125398130c1becf331b4d6a3a17dc1c5d38a16c7c82183010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffffc616139a6c9f209bc1b16d9acf00f934f7e7f7629cc1cd0aa606cbb6881b1811010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0100e1f505000000001976a9140962ce10b3f20ce12334a36f220d2a3ec6d6b10188ac000247304402203ca707f45f96cf1c074ab5d85bd97fc2f27346300d4bb22801d2dfc95c2beeec02207d5dfbb95f5a6dcf33240c4eb08207e7d336512d733a33586a261e0b40727498012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c024730440220194a7f6c7d9fcdf624a79217a25ebf66029cd1a023aabcc57eca55e8fe80d3e4022031437555badc0e209b52c66803cf9fa0001fbea64d0e7af789676ff12105161c012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");

      await destoryTest();
    });
  });
}
