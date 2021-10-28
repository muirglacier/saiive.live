import 'package:saiive.live/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;
  static const double COIND = 100000000.0;

  static getExplorerUrlForNet(ChainType chainType, ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        if (chainType == ChainType.DeFiChain)
          return "https://explorer.saiive.live/#/DFI/mainnet";
        else if (chainType == ChainType.Bitcoin) return "https://explorer.saiive.live/#/BTC/mainnet";
        break;
      case ChainNet.Testnet:
        if (chainType == ChainType.DeFiChain)
          return "https://explorer.saiive.live/#/DFI/testnet";
        else if (chainType == ChainType.Bitcoin) return "https://explorer.saiive.live/#/BTC/testnet";
        break;
    }
    return "https://explorer.saiive.live";
  }

  static getExplorerUrl(ChainType chain, ChainNet net, String txId) {
    return getExplorerUrlForNet(chain, net) + "/tx/" + txId;
  }

  static getExplorerAddressUrl(ChainType chain, ChainNet net, String address) {
    return getExplorerUrlForNet(chain, net) + "/address/" + address;
  }

  static getExplorerBlockUrl(ChainType chain, ChainNet net, String blockHash) {
    return getExplorerUrlForNet(chain, net) + "/block/" + blockHash;
  }
}
