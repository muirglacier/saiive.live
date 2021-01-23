import 'package:defichainwallet/network/account_service.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/fee_service.dart';
import 'package:defichainwallet/network/http_service.dart';
import 'package:defichainwallet/network/transaction_service.dart';
import 'package:defichainwallet/network/block_service.dart';
import 'package:get_it/get_it.dart';

import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/network/model/vault.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<Vault>(() => Vault());
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<AccountService>(() => AccountService());
  sl.registerLazySingleton<BalanceService>(() => BalanceService());
  sl.registerLazySingleton<TransactionService>(() => TransactionService());
  sl.registerLazySingleton<FeeService>(() => FeeService());
  sl.registerLazySingleton<BlockService>(() => BlockService());
}