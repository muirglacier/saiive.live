import 'package:saiive.live/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;
  static const double COIND = 100000000.0;
  static const double DEFAULT_SLIPPAGE = 0.05;

  static getExplorerUrlForNet(ChainType chainType, ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        if (chainType == ChainType.DeFiChain)
          return "https://defiscan.live/";
        else if (chainType == ChainType.Bitcoin) return "https://explorer.saiive.live/#/BTC/mainnet";
        break;
      case ChainNet.Testnet:
        if (chainType == ChainType.DeFiChain)
          return "https://defiscan.live/";
        else if (chainType == ChainType.Bitcoin) return "https://explorer.saiive.live/#/BTC/testnet";
        break;
    }
    return "https://explorer.saiive.live";
  }

  static getExplorerUrl(ChainType chain, ChainNet net, String txId) {
    return getExplorerUrlForNet(chain, net) + "/transactions/" + txId + (net == ChainNet.Testnet ? "?network=TestNet" : "");
  }

  static getExplorerAddressUrl(ChainType chain, ChainNet net, String address) {
    return getExplorerUrlForNet(chain, net) + "/address/" + address + (net == ChainNet.Testnet ? "?network=TestNet" : "");
  }

  static getExplorerBlockUrl(ChainType chain, ChainNet net, String blockHash) {
    return getExplorerUrlForNet(chain, net) + "/blocks/" + blockHash + (net == ChainNet.Testnet ? "?network=TestNet" : "");
  }
}
