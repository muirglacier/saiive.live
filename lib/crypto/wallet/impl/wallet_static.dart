import '../wallet-sync.dart';

class WalletStaticHelper {
  static Future syncUtxo(Map dataMap) async {
    return await WalletSync.syncUTXO(
        dataMap["chain"],
        dataMap["network"],
        dataMap["seed"],
        dataMap["password"],
        dataMap["apiService"],
        dataMap["accounts"]);
  }

  static Future syncWallet(Map dataMap) async {
    return await WalletSync.syncBalance(
        dataMap["chain"],
        dataMap["network"],
        dataMap["seed"],
        dataMap["password"],
        dataMap["apiService"],
        dataMap["accounts"]);
  }

  static Future syncTransactions(Map dataMap) async {
    return await WalletSync.syncTransactions(
        dataMap["chain"],
        dataMap["network"],
        dataMap["seed"],
        dataMap["password"],
        dataMap["apiService"],
        dataMap["accounts"]);
  }
}
