import 'package:saiive.live/crypto/chain.dart';

class DefiChainConstants {
  static const String MnemonicKey = "mnemonic";
  static const String WorkingAccountKey = "workingAccount";
  static const String RecoveryPhraseTested = "recoveryPhraseTested";
  static const String ThemeBrightness = "theme_brightness";

  static const int COIN = 100000000;

  static getExplorerUrlForNet(ChainType chainType, ChainNet net) {
    switch (net) {
      case ChainNet.Mainnet:
        if (chainType == ChainType.DeFiChain)
          return "https://mainnet-supernode.saiive.live/explorer/#/DFI/mainnet";
        else
          return "https://blockstream.info";
        break;
      case ChainNet.Testnet:
        if (chainType == ChainType.DeFiChain)
          return "https://testnet-supernode.saiive.live/testnet/#/DFI/testnet";
        else
          return "https://blockstream.info/testnet";
        break;
    }
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
