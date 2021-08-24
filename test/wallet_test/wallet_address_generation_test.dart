import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
import 'wallet_test_base.dart';

void main() async {
  await testSetup("sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 create tx", () {
    initTest() async {
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
    }

    Future destroyTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 test create addresses", () async {
      await initTest();
      final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      final walletAccount = WalletAccount(Uuid().v4(),
          id: 0,
          chain: ChainType.DeFiChain,
          account: 0,
          walletAccountType: WalletAccountType.HdAccount,
          derivationPathType: PathDerivationType.FullNodeWallet,
          name: "acc",
          selected: true);

      var address = await wallet.getPublicKey(false, AddressType.P2SHSegwit);
      var address2 = await wallet.getPublicKey(false, AddressType.P2SHSegwit);

      expect(address, address2);

      await db.addTransaction(
          Transaction(
              id: "601496faf1963a034ec57842",
              chain: "DFI",
              network: "testnet",
              mintIndex: 1,
              mintTxId: "c06adf474ef073fa320ab531bfc366546a9e2db2c39eac9e696790f30f428371",
              mintHeight: 192706,
              spentHeight: -2,
              address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv",
              value: 1000000000,
              confirmations: -1),
          walletAccount);

      var address3 = await wallet.getPublicKey(false, AddressType.P2SHSegwit);

      expect(address, isNot(equals(address3)));

      await destroyTest();
    });
  });
}
