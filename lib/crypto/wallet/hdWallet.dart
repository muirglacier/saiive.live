import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/account.dart';

abstract class IHdWallet {
  Future<List<Account>> syncBalance();

  Future<String> nextFreePublicKey(IWalletDatabase database, bool isChangeAddress);
}
