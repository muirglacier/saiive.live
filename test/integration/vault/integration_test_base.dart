import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/account_service.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:saiive.live/network/balance_service.dart';
import 'package:saiive.live/network/healthcheck_service.dart';
import 'package:saiive.live/network/http_service.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/network/transaction_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/env_service.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../wallet_test/mock/memory_database_factory_mock.dart';
import '../../wallet_test/mock/sharedprefs_mock.dart';
import '../../wallet_test/mock/vault_mock.dart';

Future testSetupIntegration(String seed) async {
  SharedPreferences.setMockInitialValues({});

  dotenv.testLoad(fileInput: '''API_URL="https://dev-supernode.saiive.live"''');

  setupTestServiceLocator(seed);

  await sl.allReady();
}

Future baseInit() async {
  final db = await sl.get<IWalletDatabaseFactory>().getDatabase(ChainType.DeFiChain, ChainNet.Testnet);

  final wallet = sl.get<DeFiChainWallet>();
  final walletAccount = WalletAccount(Uuid().v4(),
      id: 0,
      chain: ChainType.DeFiChain,
      account: 0,
      walletAccountType: WalletAccountType.HdAccount,
      derivationPathType: PathDerivationType.FullNodeWallet,
      name: "acc",
      selected: true);
  await db.addOrUpdateAccount(walletAccount);

  final dfiToken =
      Account(token: DeFiConstants.DefiTokenSymbol, address: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", balance: 500 * 100000000, raw: "@DFI", chain: "DFI", network: "testnet");

  await db.setAccountBalance(dfiToken, walletAccount);

  await wallet.init();
  await wallet.syncAll();
}

Future destoryTest() async {
  await sl.get<IWalletDatabaseFactory>().destroy(ChainType.DeFiChain, ChainNet.Testnet);

  final wallet = sl.get<DeFiChainWallet>();
  await wallet.close();
}

void setupTestServiceLocator(String seed) {
  sl.registerLazySingleton<ISharedPrefsUtil>(() => SharedPrefsMock());
  sl.registerLazySingleton<IVault>(() => VaultMock(seed));

  sl.registerSingletonAsync<IHttpService>(() async {
    var service = HttpService();
    await service.init();
    return service;
  });

  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton<IAccountService>(() => AccountService());
  sl.registerLazySingleton<ITransactionService>(() => TransactionService());
  sl.registerLazySingleton<IBalanceService>(() => BalanceService());
  sl.registerLazySingleton<ITokenService>(() => TokenService());
  sl.registerLazySingleton<IHealthCheckService>(() => HealthCheckService());
  sl.registerLazySingleton<IHealthService>(() => HealthService());
  sl.registerLazySingleton<IEnvironmentService>(() => EnvironmentService());

  sl.registerLazySingleton<IWalletDatabaseFactory>(() => WalletDatabaseFactoryMock());
  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet(false));
  sl.registerLazySingleton<BitcoinWallet>(() => BitcoinWallet(false));
}
