import 'package:saiive.live/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;
  static const double COIND = 100000000.0;
  static const double DEFAULT_SLIPPAGE = 0.03;
  static const int BLOCK_TIME_S = 30;

  static getExplorerUrlForNet(ChainType chainType, ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        if (chainType == ChainType.DeFiChain)
          return "https://defiscan.live";
        else if (chainType == ChainType.Bitcoin) return "https://blockstream.info";
        break;
      case ChainNet.Testnet:
        if (chainType == ChainType.DeFiChain)
          return "https://defiscan.live";
        else if (chainType == ChainType.Bitcoin) return "https://blockstream.info/testnet";
        break;
    }
    return "https://explorer.saiive.live";
  }

  static getExplorerUrl(ChainType chain, ChainNet net, String txId) {
    return getExplorerUrlForNet(chain, net) +
        (chain == ChainType.DeFiChain ? "/transactions/" : "/tx/") +
        txId +
        (chain == ChainType.DeFiChain && net == ChainNet.Testnet ? "?network=TestNet" : "");
  }

  static getExplorerAddressUrl(ChainType chain, ChainNet net, String address) {
    return getExplorerUrlForNet(chain, net) + "/address/" + address + (chain == ChainType.DeFiChain && net == ChainNet.Testnet ? "?network=TestNet" : "");
  }

  static getExplorerBlockUrl(ChainType chain, ChainNet net, String blockHash) {
    return getExplorerUrlForNet(chain, net) + "/blocks/" + blockHash + (chain == ChainType.DeFiChain && net == ChainNet.Testnet ? "?network=TestNet" : "");
  }
}
