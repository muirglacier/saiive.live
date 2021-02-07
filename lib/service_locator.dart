import 'dart:io';

import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/database/wallet_db_sembast.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/coingecko_service.dart';
import 'package:defichainwallet/network/defichain_service.dart';
import 'package:defichainwallet/network/dex_service.dart';
import 'package:defichainwallet/network/gov_service.dart';
import 'package:defichainwallet/network/http_service.dart';
import 'package:defichainwallet/network/ihttp_service.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/network/pool_share_service.dart';
import 'package:defichainwallet/network/token_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/network/model/vault.dart';
import 'package:path_provider/path_provider.dart';
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
  sl.registerLazySingleton(() => AccountService());
  sl.registerLazySingleton(() => TransactionService());
  sl.registerLazySingleton(() => BalanceService());
  sl.registerLazySingleton(() => TokenService());
  sl.registerLazySingleton(() => PoolPairService());
  sl.registerLazySingleton(() => DexService());
  sl.registerLazySingleton(() => CoingeckoService());
  sl.registerLazySingleton(() => GovService());
  sl.registerLazySingleton(() => DefichainService());
  sl.registerLazySingleton(() => PoolShareService());

  sl.registerSingletonAsync<IWalletDatabase>(() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, "db", "wallet.db");
    var db = SembastWalletDatabase(path);
    await db.open();
    return db;
  });


  sl.registerLazySingleton<DeFiChainWallet>(() => DeFiChainWallet());
}
