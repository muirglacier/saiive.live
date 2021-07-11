import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saiive.live/helper/env.dart';

import 'wallet_db_sembast.dart';
import 'package:path/path.dart';

abstract class IWalletDatabaseFactory {
  Future<IWalletDatabase> getDatabase(ChainType chain, ChainNet network);
  Future<IWalletDatabase> createInstance(ChainType chain, ChainNet network);

  Future destroy(ChainType chain, ChainNet network);
}

class WalletDatabaseFactory implements IWalletDatabaseFactory {
  Map<ChainType, IWalletDatabase> _databases;

  WalletDatabaseFactory() {
    _databases = Map<ChainType, IWalletDatabase>();
  }

  Future<String> _getPath(int version, ChainType chain, ChainNet network) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    var currentEnvironment = EnvHelper.getEnvironment();
    if (version == 1) {
      return join(
          documentsDirectory.path, "saiive.live", EnvHelper.environmentToString(currentEnvironment), ChainHelper.chainTypeString(chain), ChainHelper.chainNetworkString(network));
    }
    return join(documentsDirectory.path, "saiive.live", "v" + version.toString(), EnvHelper.environmentToString(currentEnvironment), ChainHelper.chainTypeString(chain),
        ChainHelper.chainNetworkString(network));
  }

  Future<IWalletDatabase> createInstance(ChainType chain, ChainNet network) async {
    final path = await _getPath(2, chain, network);
    var db = SembastWalletDatabase(path, chain);
    await db.open();
    return db;
  }

  @override
  Future<IWalletDatabase> getDatabase(ChainType chain, ChainNet network) async {
    if (!_databases.containsKey(chain)) {
      final db = await createInstance(chain, network);
      _databases.putIfAbsent(chain, () => db);
    }

    return _databases[chain];
  }

  @override
  Future destroy(ChainType chain, ChainNet network) async {
    if (!_databases.containsKey(chain)) {
      return;
    }

    final db = await getDatabase(chain, network);
    await db.destroy();

    _databases.remove(chain);
  }
}
