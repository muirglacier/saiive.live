import 'package:defichainwallet/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;

  static getExplorerUrl(ChainNet net, String txId) {
    return "https://" + ChainHelper.chainNetworkString(net) + ".defichain.io/#/DFI/" + ChainHelper.chainNetworkString(net) + "/tx/" + txId;
  }
}
