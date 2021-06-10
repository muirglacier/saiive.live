import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
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

    test("generate samples addresses", () async {
      var mnemonic = 'sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow';

      final seedHex = defichain.mnemonicToSeedHex(mnemonic, passphrase: "");
      final seed = HEX.decode(seedHex);

      var keys = await HdWalletUtil.derivePublicKeys(seed, 0, false, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.P2SHSegwit, 20);
      var changeKeys = await HdWalletUtil.derivePublicKeys(seed, 0, true, 0, ChainType.DeFiChain, ChainNet.Testnet, AddressType.P2SHSegwit, 20);
      int i = 0;
      for (var key in keys) {
        LogHelper.instance.d("$key at $i");
        i++;
      }
      i = 0;
      for (var key in changeKeys) {
        // LogHelper.instance.d("ret $key at $i");
        i++;
      }
    });
  });
}

String getAddress(node, [network]) {
  return P2SH(data: PaymentData(redeem: P2WPKH(data: PaymentData(pubkey: node.publicKey), network: network).data), network: network).data.address;
}
