import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/database/wallet_database.dart';
import 'package:saiive.live/crypto/database/wallet_database_factory.dart';

import 'database_memory_mock.dart';

class WalletDatabaseFactoryMock extends WalletDatabaseFactory {
  @override
  Future<IWalletDatabase> createInstance(ChainType chain, ChainNet network) async {
    return MemoryDatabaseMock();
  }
}
