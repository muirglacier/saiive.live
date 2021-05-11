import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:path_provider/path_provider.dart';

import 'wallet_db_sembast.dart';
import 'package:path/path.dart';

abstract class IWalletDatabaseFactory {
  Future<IWalletDatabase> getDatabase(ChainType chain);
  Future<IWalletDatabase> createInstance(ChainType chain);

  Future destroy(ChainType chain);
}

class WalletDatabaseFactory implements IWalletDatabaseFactory {
  Map<ChainType, IWalletDatabase> _databases;

  WalletDatabaseFactory() {
    _databases = Map<ChainType, IWalletDatabase>();
  }

  Future<IWalletDatabase> createInstance(ChainType chain) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "db_" + ChainHelper.chainTypeString(chain));
    var db = SembastWalletDatabase(path);
    await db.open();
    return db;
  }

  @override
  Future<IWalletDatabase> getDatabase(ChainType chain) async {
    if (!_databases.containsKey(chain)) {
      final db = await createInstance(chain);
      _databases.putIfAbsent(chain, () => db);
    }

    return _databases[chain];
  }

  @override
  Future destroy(ChainType chain) async {
    if (!_databases.containsKey(chain)) {
      return;
    }

    final db = await getDatabase(chain);
    await db.destroy();

    _databases.remove(chain);
  }
}
