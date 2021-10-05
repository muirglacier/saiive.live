import 'dart:typed_data';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/errors/NoUtxoError.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/address_type.dart';
import 'package:saiive.live/network/model/transaction.dart' as tx;
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:tuple/tuple.dart';

class PublicPrivateKeyPair {
  final String privateKey;
  final String publicKey;

  PublicPrivateKeyPair(this.privateKey, this.publicKey);
}

const DEFICHAIN_COIN_TYPE = 1129;

class HdWalletUtil {
  static bip32.NetworkType _getNetwork(ChainType chainType, ChainNet network) {
    final networkInstance = getNetworkType(chainType, network);
    final networkType = bip32.NetworkType(bip32: bip32.Bip32Type(private: networkInstance.bip32.private, public: networkInstance.bip32.public), wif: networkInstance.wif);
    return networkType;
  }

  static bool isAddressValid(String address, ChainType chainType, ChainNet network) {
    return Address.validateAddress(address, getNetworkType(chainType, network));
  }

  static bool isPrivateKeyValid(String wifKey, ChainType chainType, ChainNet network) {
    try {
      ECPair.fromWIF(wifKey, network: getNetworkType(chainType, network));
      return true;
    } catch (e) {
      return false;
    }
  }

  static String _getEncryptionKey(PathDerivationType derivationPathType) {
    switch (derivationPathType) {
      case PathDerivationType.JellyfishBullshit:
        return "@defichain/jellyfish-wallet-mnemonic";
      default:
        return "Bitcoin seed";
    }
  }

  static bip32.BIP32 _getBip32Key(PathDerivationType derivationPathType, Uint8List seed, bip32.NetworkType networkType) {
    switch (derivationPathType) {
      case PathDerivationType.FullNodeWallet:
        final hdSeed = bip32.BIP32.fromSeedWithCustomKey(seed, _getEncryptionKey(derivationPathType), networkType);
        final xMasterPriv = bip32.BIP32.fromSeed(hdSeed.privateKey, networkType);
        return xMasterPriv;
      default:
        return bip32.BIP32.fromSeedWithCustomKey(seed, _getEncryptionKey(derivationPathType), networkType);
    }
  }

  static String getPublicKey(
      Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network, AddressType addressType, PathDerivationType derivationPathType) {
    final networkType = _getNetwork(chainType, network);

    final hdSeed = _getBip32Key(derivationPathType, seed, networkType);

    final path = derivePath(account, changeAddress, index, derivationPathType);
    final derivedKey = hdSeed.derivePath(path);
    final address = getPublicAddress(derivedKey, chainType, network, addressType);

    //   LogHelper.instance
    //     .d("PublicKey for $path is $address from xMasterPriv $xMasterPrivWif");

    return address;
  }

  static ECPair getKeyPair(Uint8List seed, int account, bool isChangeAddress, int index, ChainType chainType, ChainNet network, PathDerivationType derivationPathType) {
    final networkType = _getNetwork(chainType, network);

    final path = derivePath(account, isChangeAddress, index, derivationPathType);

    final hdSeed = _getBip32Key(derivationPathType, seed, networkType);
    final keyPair = ECPair.fromPrivateKey(hdSeed.derivePath(path).privateKey, network: getNetworkType(chainType, network));

    return keyPair;
  }

  static String getPublicAddress(bip32.BIP32 keyPair, ChainType chainType, ChainNet network, AddressType addressType) {
    switch (addressType) {
      case AddressType.Legacy:
        return _getLegacyPublicKey(keyPair.publicKey, chainType, network);
        break;
      case AddressType.P2SHSegwit:
        return _getPayToScriptHashPublicKey(keyPair.publicKey, chainType, network);
      case AddressType.Bech32:
        return _getBech32PublicKey(keyPair.publicKey, chainType, network);
      default:
        throw new ArgumentError("not supported...");
    }
  }

  static String getPublicAddressFromWif(String privateKey, ChainType chainType, ChainNet network, AddressType addressType) {
    var pair = ECPair.fromWIF(privateKey, network: getNetworkType(chainType, network));

    switch (addressType) {
      case AddressType.Legacy:
        return _getLegacyPublicKey(pair.publicKey, chainType, network);
        break;
      case AddressType.P2SHSegwit:
        return _getPayToScriptHashPublicKey(pair.publicKey, chainType, network);
      default:
        throw new ArgumentError("not supported...");
    }
  }

  static String _getLegacyPublicKey(Uint8List publicKey, ChainType chainType, ChainNet network) {
    final net = getNetworkType(chainType, network);
    final address = P2PKH(data: PaymentData(pubkey: publicKey), network: net).data.address;

    return address;
  }

  static String _getPayToScriptHashPublicKey(Uint8List publicKey, ChainType chainType, ChainNet network) {
    final net = getNetworkType(chainType, network);
    final address = P2SH(data: PaymentData(redeem: P2WPKH(data: PaymentData(pubkey: publicKey), network: net).data), network: net).data.address;

    return address;
  }

  static String _getBech32PublicKey(Uint8List publicKey, ChainType chainType, ChainNet network) {
    final net = getNetworkType(chainType, network);
    final address = P2WPKH(data: PaymentData(pubkey: publicKey), network: net).data.address;

    return address;
  }

  static AddressType getAddressType(String address, ChainType chain, ChainNet network) {
    if (chain == ChainType.Bitcoin) {
      if (network == ChainNet.Mainnet) {
        if (address.startsWith("3")) {
          return AddressType.P2SHSegwit;
        } else if (address.startsWith("1")) {
          return AddressType.Legacy;
        }
      } else {
        if (address.startsWith("2")) {
          return AddressType.P2SHSegwit;
        } else if (address.startsWith("m") || address.startsWith("n")) {
          return AddressType.Legacy;
        }
      }
    } else if (chain == ChainType.DeFiChain) {
      if (network == ChainNet.Mainnet) {
        if (address.startsWith("df")) {
          return AddressType.Bech32;
        }
        if (address.startsWith("d")) {
          return AddressType.P2SHSegwit;
        }
        if (address.startsWith("8")) {
          return AddressType.Legacy;
        }
      } else {
        if (address.startsWith("tf")) {
          return AddressType.Bech32;
        }
        if (address.startsWith("t")) {
          return AddressType.P2SHSegwit;
        }
        if (address.startsWith("7")) {
          return AddressType.Legacy;
        }
      }
    }
    return null;
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

  static int getDecimalPlaces(ChainType type) {
    return 9;
  }

  static int addInput(TransactionBuilder txb, ECPair keyPair, tx.Transaction tx, WalletAddress addressInfo, NetworkType network) {
    if (addressInfo.addressType == AddressType.Bech32) {
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: network).data;

      return txb.addInput(tx.mintTxId, tx.mintIndex, null, p2wpkh.output);
    }
    return txb.addInput(tx.mintTxId, tx.mintIndex);
  }

  static String signString(ECPair privateKey, String message, ChainType chain, ChainNet net) {
    var network = getNetworkType(chain, net);
    var signed = privateKey.signMessage(message, network);

    return signed;
  }

  static void signInput(TransactionBuilder txb, ECPair keyPair, WalletAddress addressInfo, int vin, int witnessValue) {
    if (addressInfo.addressType == AddressType.P2SHSegwit) {
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
      final redeemScript = p2wpkh.output;

      txb.sign(vin: vin, keyPair: keyPair, witnessValue: witnessValue, redeemScript: redeemScript);
    } else if (addressInfo.addressType == AddressType.Bech32) {
      txb.sign(vin: vin, keyPair: keyPair, witnessValue: witnessValue);
    } else if (addressInfo.addressType == AddressType.Legacy) {
      txb.sign(vin: vin, keyPair: keyPair);
    } else {
      throw new ArgumentError("${addressInfo.addressType} not supported...");
    }
  }

  static Future<String> buildTransaction(List<tx.Transaction> inputTxs, List<Tuple2<WalletAddress, ECPair>> keys, String to, int amount, int fee, String returnAddress,
      Function(TransactionBuilder, List<tx.Transaction>, NetworkType) additional, ChainType chain, ChainNet net,
      {int version = 4}) async {
    var network = getNetworkType(chain, net);

    if (inputTxs.length == 0) {
      throw new NoUtxoError();
    }

    assert(inputTxs.length == keys.length);

    if (inputTxs.length != keys.length) {
      throw new ArgumentError("InputTxs and Keys need to have the same size!");
    }

    final txb = TransactionBuilder(network: network);
    txb.setVersion(version);
    txb.setLockTime(0);

    int totalInputValue = 0;
    int pos = 0;
    for (final tx in inputTxs) {
      var key = keys[pos];

      addInput(txb, key.item2, tx, key.item1, network);

      final mintTxId = tx.mintTxId;
      final mintIndex = tx.mintIndex;
      final inValue = tx.value;
      LogHelper.instance.d("set tx input $mintTxId@$mintIndex input value is $inValue");

      totalInputValue += tx.valueRaw;
      pos++;
    }

    if (totalInputValue == amount) {
      //if the totalinput is equal to the amount, we just extract the fees from the amount
      amount -= fee;

      //final errorMsg = "$totalInputValue == $amount - inputValue cannot be equal to amount, we need to pay some fees!";
      //throw new InputValueEqualsTotalValueError(errorMsg, inputTxs, to, amount, fee, returnAddress);
    }

    var changeAmount = totalInputValue - amount - fee;

    if (amount > 0) {
      if (to == returnAddress) {
        var val = totalInputValue - fee;
        if (val > 0) {
          txb.addOutput(to, val);
        }
        changeAmount = 0;
      } else {
        txb.addOutput(to, amount);
      }
    }

    if (totalInputValue > (amount)) {
      if (changeAmount > 0) {
        txb.addOutput(returnAddress, changeAmount);
      }
    }

    await additional(txb, inputTxs, network);

    int index = 0;

    for (final key in keys) {
      final witnessValue = inputTxs[index].valueRaw;

      HdWalletUtil.signInput(txb, key.item2, key.item1, index, witnessValue);
      index++;
    }

    return txb.build().toHex();
  }

  static Future<String> derivePublicKey(
      Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network, AddressType addressType, PathDerivationType derivationPathType) async {
    final address = getPublicKey(seed, account, changeAddress, index, chainType, network, addressType, derivationPathType);

    return Future.value(address);
  }

  static Future<List<String>> derivePublicKeys(Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network, AddressType addressType,
      PathDerivationType derivationPathType, int count) async {
    final list = List<String>.empty(growable: true);
    for (int i = 0; i < count; i++) {
      final key = await derivePublicKey(seed, account, changeAddress, index + i, chainType, network, addressType, derivationPathType);
      list.add(key);
    }
    return list;
  }

  static Future<List<String>> derivePublicKeysWithChange(
      Uint8List seed, int account, int index, ChainType chainType, ChainNet network, AddressType addressType, PathDerivationType derivationPathType, int count) async {
    final list = List<String>.empty(growable: true);
    for (int i = 0; i < count; i++) {
      final key = await derivePublicKey(seed, account, false, index + i, chainType, network, addressType, derivationPathType);
      list.add(key);
    }
    for (int i = 0; i < count; i++) {
      final changeKey = await derivePublicKey(seed, account, true, index + i, chainType, network, addressType, derivationPathType);
      list.add(changeKey);
    }
    return list;
  }

  static String derivePath(int account, bool changeAddress, int index, PathDerivationType derivationPathType) {
    switch (derivationPathType) {
      case PathDerivationType.BIP32:
      case PathDerivationType.FullNodeWallet:
        return "m/$account'/${changeAddress ? 1 : 0}'/$index'";
        break;
      case PathDerivationType.BIP44:
        return "m/44'/$DEFICHAIN_COIN_TYPE'/$account'/${changeAddress ? 1 : 0}'/$index'";
        break;
      case PathDerivationType.JellyfishBullshit:
        return "$DEFICHAIN_COIN_TYPE/$account/${changeAddress ? 1 : 0}/$index";
        break;
      case PathDerivationType.SingleKey:
        throw ArgumentError("Not supported for single key!");
    }
    throw ArgumentError("Missing case in switch statement!");
  }

  static bool isPathChangeAddress(String path) {
    final regex = new RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");
    if (!regex.hasMatch(path)) throw new ArgumentError("Expected BIP32 Path");

    final splitted = path.split("/");
    final changeIndex = splitted[2].replaceAll("'", "");

    return changeIndex == "1";
  }

  static int getIndexFromPath(String path) {
    final regex = new RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");
    if (!regex.hasMatch(path)) throw new ArgumentError("Expected BIP32 Path");

    final splitted = path.split("/");
    final addressIndex = splitted[3].replaceAll("'", "");

    return int.parse(addressIndex);
  }

  static List<String> derivePaths(int account, bool changeAddress, int index, PathDerivationType derivationPathType, int count) {
    final list = List<String>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, changeAddress, index + i, derivationPathType));
    }
    return list;
  }

  static List<String> derivePathsWithChange(int account, int index, PathDerivationType derivationPathType, int count) {
    final list = List<String>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, false, index + i, derivationPathType));
    }
    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, true, index + i, derivationPathType));
    }
    return list;
  }
}
