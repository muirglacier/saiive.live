import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/database/wallet_database_factory.dart';

import 'database_memory_mock.dart';

class WalletDatabaseFactoryMock extends WalletDatabaseFactory {
  @override
  Future<IWalletDatabase> createInstance(ChainType chain) async {
    return MemoryDatabaseMock();
  }
}
