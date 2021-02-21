import '../wallet-sync.dart';

Future syncUtxo(Map dataMap) async {
  return await walletSyncUTXO(
      dataMap["chain"],
      dataMap["network"],
      dataMap["seed"],
      dataMap["password"],
      dataMap["apiService"],
      dataMap["accounts"]);
}

Future syncWallet(Map dataMap) async {
  return await walletSyncBalance(
      dataMap["chain"],
      dataMap["network"],
      dataMap["seed"],
      dataMap["password"],
      dataMap["apiService"],
      dataMap["accounts"]);
}

Future syncTransactions(Map dataMap) async {
  return await walletSyncTransactions(
      dataMap["chain"],
      dataMap["network"],
      dataMap["seed"],
      dataMap["password"],
      dataMap["apiService"],
      dataMap["accounts"]);
}
