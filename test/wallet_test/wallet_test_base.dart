import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/database/wallet_database_factory.dart';
import 'package:defichainwallet/crypto/wallet/bitcoin_wallet.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/healthcheck_service.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/services/health_service.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock/health_service_mock.dart';
import 'mock/http_service_mock.dart';
import 'mock/memory_database_factory_mock.dart';
import 'mock/token_service_mock.dart';
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

  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton<IAccountService>(() => AccountService());
  sl.registerLazySingleton<ITransactionService>(() => TransactionService());
  sl.registerLazySingleton<IBalanceService>(() => BalanceService());
  sl.registerLazySingleton<ITokenService>(() => TokenServiceMock());
  sl.registerLazySingleton<IHealthCheckService>(() => HealthCheckServiceMock());
  sl.registerLazySingleton<IHealthService>(() => HealthServiceMock());

  sl.registerLazySingleton<IWalletDatabaseFactory>(() => WalletDatabaseFactoryMock());
  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet(false));
  sl.registerLazySingleton<BitcoinWallet>(() => BitcoinWallet(false));
}
