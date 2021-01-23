import 'package:get_it/get_it.dart';

import 'package:defichainwallet/util/sharedprefsutil.dart';
import 'package:defichainwallet/model/vault.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<Vault>(() => Vault());
}