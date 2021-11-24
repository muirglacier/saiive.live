// import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
// import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
// import 'package:saiive.live/service_locator.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:saiive.live/crypto/chain.dart';
// import 'integration_test_base.dart';

// void main() async {
//   await testSetupIntegration(
//       "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

//   group("#1 integration vault", () {
//     Future initTest() async {
//       await baseInit();
//     }

//     Future destoryTest() async {
//       await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

//       final wallet = sl.get<DeFiChainWallet>();
//       await wallet.close();
//     }

//     test("#1 create vault", () async {
//       await initTest();

//       final wallet = sl.get<DeFiChainWallet>();

//       await wallet.init();
//       await wallet.createVault("C1000", 100000000, ownerAddress: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

//       await destoryTest();
//     }, timeout: Timeout(Duration(minutes: 10)));

//     test("#2 create vault", () async {
//       await initTest();

//       final wallet = sl.get<DeFiChainWallet>();

//       await wallet.init();
//       await wallet.createVault("C1000", 100000000);

//       await destoryTest();
//     }, timeout: Timeout(Duration(minutes: 10)));
//     test("#1 deposit to vault", () async {
//       // await initTest();

//       // final wallet = sl.get<DeFiChainWallet>();

//       // await wallet.init();
//       // await wallet.createVault("C1000", ownerAddress: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

//       // await destoryTest();
//     }, timeout: Timeout(Duration(minutes: 10)));
//   });
// }
