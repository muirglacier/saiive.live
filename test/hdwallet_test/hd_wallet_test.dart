import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/defichaindart.dart' as defichain;
import 'package:hex/hex.dart';

void main() {
  group("hd-wallet tests", () {
    test("can import recovery phrase", () {
      var mnemonic = 'sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow';

      final seed = defichain.mnemonicToSeed(mnemonic, passphrase: "");
      final xPriv = bip32.BIP32
          .fromSeed(seed, bip32.NetworkType(bip32: bip32.Bip32Type(private: defichain.testnet.bip32.private, public: defichain.testnet.bip32.public), wif: defichain.testnet.wif));

      final xMasterPriv = bip32.BIP32.fromSeed(xPriv.privateKey,
          bip32.NetworkType(bip32: bip32.Bip32Type(private: defichain.testnet.bip32.private, public: defichain.testnet.bip32.public), wif: defichain.testnet.wif));

      var eicd = defichain.ECPair.fromWIF("cMmT7Q7sy3y44zbHWvkQQRto4hMsnMHfPJNXCeaadNHjZXU5HQ88", network: defichain.defichain_testnet);

      var pubaddress = getAddress(eicd, defichain.defichain_testnet);

      expect(pubaddress, "ts8DCuUU83TaD4wfTFnbVNbK3igtBjrnKs");

      var xPrivBase58 = xMasterPriv.toBase58();
      expect(xPrivBase58, "tprv8ZgxMBicQKsPd9Gff9E9fvhL5SDCLdKbjPbaREPyjLk743Sry9nAmESmaWwijZuGqer1Q4rG1SaUhc7XHvFg6y44z6JaKmTeHyJgNQism1U");
    });

    test("generate P2SH samples addresses", () async {
      var mnemonic = 'sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow';

      final seedHex = defichain.mnemonicToSeedHex(mnemonic, passphrase: "");
      final seed = HEX.decode(seedHex);

      var keys = await HdWalletUtil.derivePublicKeys(seed, 0, false, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.P2SHSegwit, 20);
      var changeKeys = await HdWalletUtil.derivePublicKeys(seed, 0, true, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.P2SHSegwit, 20);

      expect(keys.length, 20);
      expect(changeKeys.length, 20);
      expect(keys[0], "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
      expect(keys[5], "tbdHM9N7STmuyTUtvkEMYnE3YP46ereryS");
      expect(keys[10], "tahaHMUKbAREHVD6qC4hVoBfdr1dqQdNpk");
      expect(keys[15], "tsEuvju4o4r1TWnC239iggoFnYNxufCvjZ");
      expect(keys[19], "tbyqqsmJ7YGnSCAkFeoQuoi7dxsrigwUzo");

      expect(changeKeys[0], "tf2FrPGHzU3dGKFpUBQfABwta4VrpbKFo4");
      expect(changeKeys[5], "tmfswXjX9nJjQtM2sK3kpzeaoSkium4tqk");
      expect(changeKeys[10], "tZGKNX8TibuEi44Q2GfjPX6fxCkTN75nUu");
      expect(changeKeys[15], "tkwjDyBZs6aGuQ8rNmCsJnhHxe5feYfAVe");
      expect(changeKeys[19], "ttFYF1gxSJuw4mHGahSEnYvFoX9qQDLdGx");
    });
    test("generate P2PH samples addresses", () async {
      var mnemonic = 'sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow';

      final seedHex = defichain.mnemonicToSeedHex(mnemonic, passphrase: "");
      final seed = HEX.decode(seedHex);

      var keys = await HdWalletUtil.derivePublicKeys(seed, 0, false, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.Legacy, 20);
      var changeKeys = await HdWalletUtil.derivePublicKeys(seed, 0, true, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.Legacy, 20);

      expect(keys.length, 20);
      expect(changeKeys.length, 20);
      expect(keys[0], "769pd87UohNtRVmo1NWewejJGvyKdynt9m");
      expect(keys[5], "75v6BpwQTtPTgV7nzfyB7NzLGCBQv4cnqA");
      expect(keys[10], "7G3NcVxNqMNqNKmt9qtniUsNPvoLucv8aP");
      expect(keys[15], "7HsgAfsMASEy1SH9CPc5SAsjbhYMdp4Up8");
      expect(keys[19], "7R6WwHrFevUrkLdF9kdWwLQSnpyddsjmaT");

      expect(changeKeys[0], "7RUM1jF3HTU8PC4wyJ6Kvkow9384tNHQm9");
      expect(changeKeys[5], "7LTYEKn4ENdwjgPGzeUUZevQ3f7yQVdaYS");
      expect(changeKeys[10], "7BHFuV1pTvi11kmPYDb31SGy2gRbFGJstu");
      expect(changeKeys[15], "7AQgqr9atkXgXdGosS3kbTXE6NaGbWEHmw");
      expect(changeKeys[19], "75NKZ12FbvmBNWtJbMCGXVocDfEQhEggvt");
    });
  });
}

String getAddress(node, [network]) {
  return P2SH(data: PaymentData(redeem: P2WPKH(data: PaymentData(pubkey: node.publicKey), network: network).data), network: network).data.address;
}
