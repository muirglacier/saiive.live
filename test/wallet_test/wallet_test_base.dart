import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock/database_memory_mock.dart';
import 'mock/http_service_mock.dart';
import 'mock/vault_mock.dart';

Future testSetup(String seed) async {
  SharedPreferences.setMockInitialValues({});

  setupTestServiceLocator(seed);

  await sl.allReady();
}

void setupTestServiceLocator(String seed) {
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<IVault>(() => VaultMock(seed));

  sl.registerSingletonAsync<IWalletDatabase>(() async {
    return new MemoryDatabaseMock();
  });

  sl.registerSingletonAsync<IHttpService>(() async {
    var service = MockHttpService();
    await service.init();
    return service;
  });

  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => AccountService());
  sl.registerLazySingleton(() => TransactionService());
  sl.registerLazySingleton(() => BalanceService());
  sl.registerLazySingleton<ITokenService>(() => TokenService());

  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet());
}
