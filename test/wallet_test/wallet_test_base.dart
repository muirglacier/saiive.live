import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/network/account_service.dart';
import 'package:saiive.live/network/api_service.dart';
import 'package:saiive.live/network/balance_service.dart';
import 'package:saiive.live/network/healthcheck_service.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/network/transaction_service.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/env_service.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock/environment_service_mock.dart';
import 'mock/health_service_mock.dart';
import 'mock/http_service_mock.dart';
import 'mock/memory_database_factory_mock.dart';
import 'mock/token_service_mock.dart';
import 'mock/transaction_service_mock.dart';
import 'mock/vault_mock.dart';

Future testSetup(String seed) async {
  SharedPreferences.setMockInitialValues({});

  setupTestServiceLocator(seed);

  await sl.allReady();
}

void setupTestServiceLocator(String seed) {
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<IVault>(() => VaultMock(seed));

  sl.registerSingletonAsync<IHttpService>(() async {
    var service = MockHttpService();
    await service.init();
    return service;
  });

  var transactionServiceMock = new TransactionServiceMock();

  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton<IAccountService>(() => AccountService());
  sl.registerLazySingleton<ITransactionService>(() => transactionServiceMock);
  sl.registerLazySingleton<TransactionServiceMock>(() => transactionServiceMock);
  sl.registerLazySingleton<IBalanceService>(() => BalanceService());
  sl.registerLazySingleton<ITokenService>(() => TokenServiceMock());
  sl.registerLazySingleton<IHealthCheckService>(() => HealthCheckServiceMock());
  sl.registerLazySingleton<IHealthService>(() => HealthServiceMock());
  sl.registerLazySingleton<IEnvironmentService>(() => EnvironmentServiceMock());

  sl.registerLazySingleton<IWalletDatabaseFactory>(() => WalletDatabaseFactoryMock());
  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet(false));
  sl.registerLazySingleton<BitcoinWallet>(() => BitcoinWallet(false));
}
