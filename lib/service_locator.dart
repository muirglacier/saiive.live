import 'package:defichainwallet/appcenter/appcenter.dart';
import 'package:defichainwallet/crypto/wallet/bitcoin_wallet.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/account_history_service.dart';
import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/block_service.dart';
import 'package:defichainwallet/network/coingecko_service.dart';
import 'package:defichainwallet/network/defichain_service.dart';
import 'package:defichainwallet/network/dex_service.dart';
import 'package:defichainwallet/network/gov_service.dart';
import 'package:defichainwallet/network/healthcheck_service.dart';
import 'package:defichainwallet/network/http_service.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/network/pool_share_service.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';
import 'package:defichainwallet/services/health_service.dart';
import 'package:defichainwallet/services/wallet_service.dart';
import 'package:defichainwallet/ui/testrun/test_run_service.dart';
import 'package:defichainwallet/ui/utils/authentication_helper.dart';
import 'package:defichainwallet/ui/utils/biometrics.dart';
import 'package:defichainwallet/ui/utils/hapticutil.dart';
import 'package:get_it/get_it.dart';

import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/network/model/vault.dart';
import 'network/api_service.dart';
import 'network/ihttp_service.dart';
import 'network/model/ivault.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<IVault>(() => Vault());
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
  sl.registerLazySingleton<IPoolPairService>(() => PoolPairService());
  sl.registerLazySingleton<IDexService>(() => DexService());
  sl.registerLazySingleton<ICoingeckoService>(() => CoingeckoService());
  sl.registerLazySingleton<IGovService>(() => GovService());
  sl.registerLazySingleton<IDefichainService>(() => DefichainService());
  sl.registerLazySingleton<IPoolShareService>(() => PoolShareService());
  sl.registerLazySingleton<IAccountHistoryService>(() => AccountHistoryService());
  sl.registerLazySingleton<BlockService>(() => BlockService());
  sl.registerLazySingleton<BiometricUtil>(() => BiometricUtil());
  sl.registerLazySingleton<HapticUtil>(() => HapticUtil());
  sl.registerLazySingleton<AuthenticationHelper>(() => AuthenticationHelper());
  sl.registerLazySingleton<IHealthCheckService>(() => HealthCheckService());
  sl.registerLazySingleton<IHealthService>(() => HealthService());
  sl.registerLazySingleton<ITestInfoService>(() => TestInfoService());

  sl.registerLazySingleton<AppCenterWrapper>(() => AppCenterWrapper());

  sl.registerLazySingleton<IWalletService>(() => WalletService());
  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet(true));
  sl.registerLazySingleton<BitcoinWallet>(() => BitcoinWallet(true));
}
