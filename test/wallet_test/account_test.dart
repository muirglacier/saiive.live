import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'mock/transaction_service_mock.dart';
import 'wallet_test_base.dart';

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
          derivationPathType: DerivationPathType.FullNodeWallet,
          name: "acc",
          selected: true);
      await db.addOrUpdateAccount(walletAccount);

      final tx = Transaction(
          id: "6022346c779edc3b789bc5b9",
          chain: "DFI",
          network: "testnet",
          mintIndex: 0,
          mintTxId: "2d843ac6f1f3dc3fc8dcc9e6730b2d918bda62ff03fd2305beb6671d4fee5fbb",
          mintHeight: 214903,
          spentHeight: -2,
          address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
          value: 30000000000,
          confirmations: -1);
      await db.addTransaction(tx, walletAccount);
      await db.addUnspentTransaction(tx, walletAccount);

      final account = Account(
          token: DeFiConstants.DefiAccountSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 17447697269, raw: "174.47697269@DFI", chain: "DFI", network: "testnet");

      await db.setAccountBalance(account, walletAccount);

      final btcAccount = Account(token: "BTC", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 20870745814, raw: "208.70745814@BTC", chain: "DFI", network: "testnet");

      await db.setAccountBalance(btcAccount, walletAccount);

      final dfiAccount = Account(token: "\$DFI", address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 30000000000, raw: "300@BTC", chain: "DFI", network: "testnet");

      await db.setAccountBalance(dfiAccount, walletAccount);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 test invalid utxo and account for DFI", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      expect(() => wallet.createSendTransaction(500 * 100000000, DeFiConstants.DefiTokenSymbol, "tgoVbmjxpgMHzj22y6PUPRcr7WxasGAx3n"), throwsA(isA<ArgumentError>()));

      await destoryTest();
    });
    test("#2 create tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      final txController = sl.get<TransactionServiceMock>();

      await wallet.init();
      await wallet.createSendTransaction(1 * 100000000, DeFiConstants.DefiTokenSymbol, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(txController.lastTx,
          "04000000000101bb5fee4f1d67b6be0523fd03ff62da8b912d0b73e6c9dcc83fdcf3f1c63a842d000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff0200e1f5050000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870070c92df60600000017a9146015a95984366c654bbd6ab55edab391ff8d747f870002483045022100ecfa04674739bb7501ea034dc2a193ccdf36dffbd5542d9b3644711d27f10e2d02201b252f1ec8933d20fd3bce2b7b4a9c6613e1afd6264bd36378bb8b37eb5a7a45012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });

    test("#3 create btc tx - fail", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      expect(() => wallet.createSendTransaction(500 * 100000000, "BTC", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv"), throwsA(isA<ArgumentError>()));
      await destoryTest();
    });

    test("#4 create dBTC accountToAccount tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.init();

      await wallet.createSendTransaction(1 * 100000000, "BTC", "tgoVbmjxpgMHzj22y6PUPRcr7WxasGAx3n");

      final txController = sl.get<TransactionServiceMock>();

      expect(txController.lastTx,
          "04000000000101bb5fee4f1d67b6be0523fd03ff62da8b912d0b73e6c9dcc83fdcf3f1c63a842d000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff020000000000000000456a43446654784217a9141084ef98bacfecbc9f140496b26516ae55d79bfa870117a914739bfb5d214c04655148eb21d91cdae8bb903fa387010100000000e1f5050000000000609c23fc0600000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa870002483045022100ce30176475b48bc8a919df58e4de4e77784c7b254f5fdd3c6142848ebc458206022013f93194ff901a3f71ddf9727533de796b03275b448ab32e1a3420fddbaeefd3012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
      await destoryTest();
    });
    test("#4 create dBTC accountToAccount to self tx", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final tx = await wallet.createSendTransaction(1 * 100000000, "BTC", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(tx, "");
      await destoryTest();
    });
  });
}
