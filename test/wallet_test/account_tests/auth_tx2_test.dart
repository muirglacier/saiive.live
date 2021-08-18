import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import '../wallet_test_base.dart';

void main() async {
  await testSetup("turn satisfy will globe coyote absorb agent bean steak marriage double kiss business grant object awake feed toy chef person extra hard worth mobile");

  group("#1 create tx", () {
    Future initTest() async {
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);
      final walletAccount = WalletAccount(Uuid().v4(), id: 0, chain: ChainType.DeFiChain, account: 0, walletAccountType: WalletAccountType.HdAccount, name: "acc", selected: true);
      await db.addOrUpdateAccount(walletAccount);

      final tx = Transaction(
          id: "611b7952627ac98545357146",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "179c58dbb9f2c53943395448b085c20b66cc9f67fd8cab24b41505983fbe943c",
          mintHeight: 521731,
          spentHeight: -2,
          address: "tt4MojXh1hGZLqdbtxi9FH32GYGMyQQaRk",
          value: 173848,
          confirmations: 5);

      await db.addTransaction(tx, walletAccount);
      await db.addUnspentTransaction(tx, walletAccount);

      final tx2 = Transaction(
          id: "611b7a6d627ac985453e6e08",
          chain: "DFI",
          network: "testnet",
          mintIndex: 1,
          mintTxId: "c269f7a7f6fae53d3ce632b51049417c36c84a6c36ce064d20c7b274d05f7f33",
          mintHeight: 521745,
          spentHeight: -2,
          address: "tqV35Lx6H6PXwjp44AU3VHJUmgPof68j82",
          value: 199600,
          confirmations: 3);

      await db.addTransaction(tx2, walletAccount);
      await db.addUnspentTransaction(tx2, walletAccount);
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
      final tx = await wallet.createAuthTx("tqV35Lx6H6PXwjp44AU3VHJUmgPof68j82", 200000);
      expect(tx.item1,
          "04000000000102337f5fd074b2c7204d06ce366c4ac8367c414910b532e63c3de5faf6a7f769c201000000171600143076f47145db1c6fb12abd6bd22374ab7f3f0453ffffffff3c94be3f980515b424ab8cfd679fcc660bc285b04854394339c5f2b9db589c1701000000171600149c4bc3ff65d57eb50b44c90eff6482e9f8634b17ffffffff020000000000000000076a054466547841003eb005000000000017a914d2d77c290efda41e225fb00285427a52abaa6f6b870002473044022029ebf3b48160a40374dfa0600ab41cc571ef01cd700fc4e09df3b2d545ccb671022023887c6b237910500440bc5782e30a34b70969582630fca67f240edaf15e612d0121036a02a056f4fb48fb3f84ce9f9a5ea7f52bc838207ab9dd982e3ab9f26c2a91c502473044022012157e3a596a24d6c284a6b11b2057b7c2e6446f845b1066ec78702d7f6bda4902203ade035baf74d075ab8984315360d266e31c186adc8573bb8770c9845c6febad0121032c03a53385b0640d32b7e193135e9e97c549ae42207dbcfde8b9537ae8fb53e500000000");
      await destoryTest();
    });
  });
}
