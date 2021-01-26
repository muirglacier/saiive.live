import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';

class PublicPrivateKeyPair {
  final String privateKey;
  final String publicKey;

  PublicPrivateKeyPair(this.privateKey, this.publicKey);
}

class HdWalletUtil {
  static Future<String> getPublicKey(
      Uint8List seed,
      int account,
      bool changeAddress,
      int index,
      ChainType chainType,
      ChainNet network) async {
    final networkInstance = getNetworkType(chainType, network);
    final networkType = bip32.NetworkType(
        bip32: bip32.Bip32Type(
            private: networkInstance.bip32.private,
            public: networkInstance.bip32.public),
        wif: networkInstance.wif);
        
    final hdSeed = bip32.BIP32.fromSeed(seed, networkType);
    final xMasterPriv = bip32.BIP32.fromSeed(hdSeed.privateKey, networkType);

    final path = derivePath(account, changeAddress, index);
    final address =
        await _getPublicAddress(xMasterPriv.derivePath(path), chainType, network);

    return address;
  }

  static Future<String> _getPublicAddress(
      bip32.BIP32 keyPair, ChainType chainType, ChainNet network) async {
    final net = getNetworkType(chainType, network);
    final address = P2SH(
            data: PaymentData(
                redeem: P2WPKH(
                        data: PaymentData(pubkey: keyPair.publicKey),
                        network: net)
                    .data),
            network: net)
        .data
        .address;

    return address;
  }

  static NetworkType getNetworkType(ChainType chain, ChainNet network) {
    switch (chain) {
      case ChainType.Bitcoin:
        return network == ChainNet.Testnet ? testnet : bitcoin;

      case ChainType.DeFiChain:
        return network == ChainNet.Testnet ? defichain_testnet : defichain;
    }
    throw new Exception("invalid chain..");
  }

  // static Future<String> deriveKey(
  //     Uint8List seed, int account, bool changeAddress, int index) {
  //   var path = derivePath(account, changeAddress, index);
  //   var key = ED25519_HD_KEY.derivePath(path, HEX.encode(seed));

  //   return Future<String>.value(base58.encode(key.key));
  // }

  // static Future<List<String>> deriveKeys(Uint8List seed, int account,
  //     bool changeAddress, int index, int count) async {
  //   final list = List<String>();
  //   print("deriveKey");
  //   for (int i = 0; i < count; i++) {
  //     list.add(await deriveKey(seed, account, changeAddress, index + i));
  //   }
  //   return list;
  // }

  // static Future<PublicPrivateKeyPair> derivePublicPrivateKey(
  //     Uint8List seed, int account, bool changeAddress, int index) async {
  //   var path = derivePath(account, changeAddress, index);

  //   var key = ED25519_HD_KEY.derivePath(path, HEX.encode(seed));
  //   var pub = ED25519_HD_KEY.getBublickKey(key.key, false);

  //   return Future<PublicPrivateKeyPair>.value(
  //       PublicPrivateKeyPair(base58.encode(key.key), base58.encode(pub)));
  // }

  // static Future<List<PublicPrivateKeyPair>> derivePublicPrivateKeys(
  //     Uint8List seed,
  //     int account,
  //     bool changeAddress,
  //     int index,
  //     int count) async {
  //   final list = List<PublicPrivateKeyPair>();
  //   print("deriveKey");
  //   for (int i = 0; i < count; i++) {
  //     list.add(await derivePublicPrivateKey(
  //         seed, account, changeAddress, index + i));
  //   }
  //   print("deriveKey...done");
  //   return list;
  // }

  static Future<String> derivePublicKey(
      Uint8List seed,
      int account,
      bool changeAddress,
      int index,
      ChainType chainType,
      ChainNet network) async {
    return await getPublicKey(
        seed, account, changeAddress, index, chainType, network);
  }

  static Future<List<String>> derivePublicKeys(
      Uint8List seed,
      int account,
      bool changeAddress,
      int index,
      ChainType chainType,
      ChainNet network,
      int count) async {
    final list = List<String>.empty(growable: true);
    print("derivePublicKey");
    for (int i = 0; i < count; i++) {
      final key = await derivePublicKey(
          seed, account, changeAddress, index + i, chainType, network);
      list.add(key);
    }
    print("derivePublicKey...done");
    return list;
  }

  static String derivePath(int account, bool changeAddress, int index) {
    return "m/$account'/${changeAddress ? 1 : 0}'/$index'";
  }

  static List<String> derivePaths(
      int account, bool changeAddress, int index, int count) {
    final list = List<String>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, changeAddress, index + i));
    }
    return list;
  }
}
