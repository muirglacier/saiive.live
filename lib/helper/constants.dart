import 'package:saiive.live/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;

  static getExplorerUrlForNet(ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        return "https://mainnet-supernode.saiive.live/explorer/#/DFI/mainnet/";
        break;
      case ChainNet.Testnet:
        return "https://testnet-supernode.saiive.live/testnet/#/DFI/testnet/";
        break;
    }
  }

  static getExplorerUrl(ChainNet net, String txId) {
    return getExplorerUrlForNet(net) + "/tx/" + txId;
  }

  static getExplorerBlockUrl(ChainNet net, String blockHash) {
    return getExplorerUrlForNet(net) + "/block/" + blockHash;
  }
}
