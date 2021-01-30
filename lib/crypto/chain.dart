enum ChainType { Bitcoin, DeFiChain }

enum ChainNet { Mainnet, Testnet }

class ChainHelper {
  static String chainTypeString(ChainType type) {
    switch (type) {
      case ChainType.Bitcoin:
        return "BTC";
      case ChainType.DeFiChain:
        return "DFI";
    }

    return null;
  }

  static String chainNetworkString(ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        return "mainnet";
      case ChainNet.Testnet:
        return "testnet";
    }
    return null;
  }

  static ChainType chainFromString(String chain) {
    if (chain == null || chain.isEmpty) {
      throw new ArgumentError();
    }

    if(chain.toLowerCase() == "dfi") {
      return ChainType.DeFiChain;
    }
    return ChainType.Bitcoin;
  }

  static ChainNet networkFromString(String network) {
    if (network == null || network.isEmpty) {
      throw new ArgumentError();
    }

    if(network.toLowerCase() == "testnet") {
      return ChainNet.Testnet;
    }
    return ChainNet.Mainnet;
  }
}
