import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:saiive.live/appcenter/appcenter.dart';
import 'package:saiive.live/channel.dart';
import 'package:saiive.live/crypto/addressbook/address_book_db.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';
import 'package:saiive.live/crypto/wallet/bitcoin_wallet.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/network/account_history_service.dart';
import 'package:saiive.live/network/account_service.dart';
import 'package:saiive.live/network/balance_service.dart';
import 'package:saiive.live/network/block_service.dart';
import 'package:saiive.live/network/coingecko_service.dart';
import 'package:saiive.live/network/defichain_service.dart';
import 'package:saiive.live/network/dex_service.dart';
import 'package:saiive.live/network/gov_service.dart';
import 'package:saiive.live/network/healthcheck_service.dart';
import 'package:saiive.live/network/http_service.dart';
import 'package:saiive.live/network/ihttp_service.dart';
import 'package:saiive.live/network/loans_auctions_service.dart';
import 'package:saiive.live/network/loans_service.dart';
import 'package:saiive.live/network/pool_pair_service.dart';
import 'package:saiive.live/network/pool_share_service.dart';
import 'package:saiive.live/network/stats.dart';
import 'package:saiive.live/network/token_service.dart';
import 'package:saiive.live/network/transaction_service.dart';
import 'package:saiive.live/network/vaults_service.dart';
import 'package:saiive.live/services/background.dart';
import 'package:saiive.live/services/desktop_vault.dart';
import 'package:saiive.live/services/env_service.dart';
import 'package:saiive.live/services/health_service.dart';
import 'package:saiive.live/services/stats_background.dart';
import 'package:saiive.live/services/wallet_service.dart';
import 'package:saiive.live/ui/lock/desktop_unlock_handler.dart';
import 'package:saiive.live/ui/lock/mobile_unlock_handler.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/ui/testrun/test_run_service.dart';
import 'package:saiive.live/ui/utils/authentication_helper.dart';
import 'package:saiive.live/ui/utils/biometrics.dart';
import 'package:saiive.live/ui/utils/hapticutil.dart';
import 'package:get_it/get_it.dart';

import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:saiive.live/services/mobile_vault.dart';
import 'network/api_service.dart';
import 'network/ihttp_service.dart';
import 'network/model/ivault.dart';
import 'package:path/path.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<ISharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<IVault>(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return DesktopVault();
    }
    return MobileVault();
  });
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
  sl.registerLazySingleton<ILoansService>(() => LoansService());
  sl.registerLazySingleton<IVaultsService>(() => VaultsService());
  sl.registerLazySingleton<ILoansAuctionsService>(() => LoansAuctionsService());
  sl.registerLazySingleton<IStatsService>(() => StatsService());
  sl.registerLazySingleton<StatsBackgroundService>(() => StatsBackgroundService());
  sl.registerLazySingleton<BackgroundService>(() => BackgroundService());

  sl.registerLazySingleton<AppCenterWrapper>(() => AppCenterWrapper());

  sl.registerLazySingleton<IWalletDatabaseFactory>(() => WalletDatabaseFactory());

  sl.registerLazySingleton<IWalletService>(() => WalletService());
  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet(true));
  sl.registerLazySingleton<BitcoinWallet>(() => BitcoinWallet(true));
  sl.registerLazySingleton<ChannelConnection>(() => ChannelConnection());

  sl.registerLazySingleton<IEnvironmentService>(() => EnvironmentService());

  sl.registerLazySingleton<IUnlockHandler>(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return DesktopUnlockHandler();
    }
    return MobileUnlockHandler();
  });

  sl.registerSingletonAsync<IAddressBookDatabase>(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    var currentEnvironment = EnvHelper.getEnvironment();

    var path = join(documentsDirectory.path, "saiive.live", EnvHelper.environmentToString(currentEnvironment));
    var service = AddressBookDatabase(path);

    return service;
  });
}
