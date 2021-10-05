import 'dart:typed_data';

import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:uuid/uuid.dart';
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
          derivationPathType: PathDerivationType.FullNodeWallet,
          name: "acc",
          selected: true);
      await db.addOrUpdateAccount(walletAccount);
    }

    Future destoryTest() async {
      await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

      final wallet = sl.get<DeFiChainWallet>();
      await wallet.close();
    }

    test("#1 sign message", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

      var signedMsg = await wallet.signMessage("tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", "test");
      expect("IPoqU14FRp2P6pYcs+5f3CSLtX6ioVw+w6RLfwfT8f6IWYZmV8JdhnjzTOta1HiVZE8OM67TNNNJMLdQ5yRc5IE=", signedMsg);

      await destoryTest();
    });

    test("#2 sign message", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      var network = HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Mainnet);
      //pub key 8YBhdwtkkS1qPzwdXPX1pvm5wCersjBhV5
      var signedMsg =
          HdWalletUtil.signString(ECPair.fromWIF("L1MYKXoYaKM2tf6iCiEXAv4J3cAK4GazAUePPVBpBXDqHVqyx2Ff", network: network), "test", ChainType.DeFiChain, ChainNet.Mainnet);
      expect("IHWoPpeCPNTTkReJ+MTAPZtkXDWQIAkw52fvyXX8uuztBHllF/MUwapmGv5cVAIdcNk/m9FwFhhAi39Db6Re7Cg=", signedMsg);

      await destoryTest();
    });
    test("#3 sign message", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      //pub key 8YBhdwtkkS1qPzwdXPX1pvm5wCersjBhV
      var network = HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Mainnet);
      var privateKey = ECPair.fromWIF("L1MYKXoYaKM2tf6iCiEXAv4J3cAK4GazAUePPVBpBXDqHVqyx2Ff", network: network);
      var msgToSign =
          "By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_8YBhdwtkkS1qPzwdXPX1pvm5wCersjBhV5";
      var signedMsg = HdWalletUtil.signString(privateKey, msgToSign, ChainType.DeFiChain, ChainNet.Mainnet);
      expect("IDZaeRmB7HNNsmyUPNliSqnJQ8IfBi35JHi5e31zvCFtZN10VlV9cxhHUrYDUO7kEPVLweSGTtzuVK6KykcV4l4=", signedMsg);

      await destoryTest();
    });

    test("#4 sign message", () async {
      await initTest();

      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();
      //pub key 8YBhdwtkkS1qPzwdXPX1pvm5wCersjBhV

      var network = HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Mainnet);
      var privArra = Uint8List.fromList(
          [13, 255, 118, 1, 213, 120, 252, 189, 147, 183, 212, 129, 212, 200, 196, 203, 235, 133, 92, 90, 70, 96, 130, 185, 232, 102, 123, 118, 65, 28, 208, 167]);
      var privateKey = ECPair.fromPrivateKey(privArra, network: network);

      var msgToSign =
          "By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_df1q395uhj7jy70atgtrtgc8nzp0kqnk7424fg2v2s";
      var signedMsg = HdWalletUtil.signString(privateKey, msgToSign, ChainType.DeFiChain, ChainNet.Mainnet);
      expect("H7tV5q32uRwtzzVSGcrfiHMKAlCCkHUwNK7iu+cZ5XctQCWXu552gNAliqGoZkh7/mi4Ps9AlXUzo4fgfRre9R0=", signedMsg);

      await destoryTest();
    });
  });
}
