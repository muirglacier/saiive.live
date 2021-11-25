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

  group("#1 create vault", () {
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
          value: 200000000,
          confirmations: -1);
      await db.addTransaction(tx, walletAccount);
      await db.addUnspentTransaction(tx, walletAccount);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 create vault tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      await wallet.createVault("C1000", 100000000, ownerAddress: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      final txController = sl.get<TransactionServiceMock>();
      expect(txController.lastTx,
          "0400000000010162ed76c00628d0a386125398130c1becf331b4d6a3a17dc1c5d38a16c7c82183010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0200e1f50500000000256a23446654785617a9141084ef98bacfecbc9f140496b26516ae55d79bfa8705433130303000aeddf5050000000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700024830450221008dbc20b788557069d6cf8d923a868eea657a9b3d19063801b88cdc14e89ad0db022010b99f3791e1b363fd883e2e88345c1ed55ea6b81a3466d8ce9b3f701acf373e012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");

      await destoryTest();
    });
  });
}