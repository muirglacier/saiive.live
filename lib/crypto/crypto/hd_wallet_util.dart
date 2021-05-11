import 'dart:typed_data';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/network/model/transaction.dart' as tx;
import 'package:defichainwallet/helper/logger/LogHelper.dart';

import 'from_account.dart';

class PublicPrivateKeyPair {
  final String privateKey;
  final String publicKey;

  PublicPrivateKeyPair(this.privateKey, this.publicKey);
}

class HdWalletUtil {
  static bip32.NetworkType _getNetwork(ChainType chainType, ChainNet network) {
    final networkInstance = getNetworkType(chainType, network);
    final networkType = bip32.NetworkType(bip32: bip32.Bip32Type(private: networkInstance.bip32.private, public: networkInstance.bip32.public), wif: networkInstance.wif);
    return networkType;
  }

  static Future<String> getPublicKey(Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network) async {
    final networkType = _getNetwork(chainType, network);

    final hdSeed = bip32.BIP32.fromSeed(seed, networkType);
    final xMasterPriv = bip32.BIP32.fromSeed(hdSeed.privateKey, networkType);

    final path = derivePath(account, changeAddress, index);

    final address = await _getPublicAddress(xMasterPriv.derivePath(path), chainType, network);

    //   LogHelper.instance
    //     .d("PublicKey for $path is $address from xMasterPriv $xMasterPrivWif");

    return address;
  }

  static ECPair getKeyPair(Uint8List seed, int account, bool isChangeAddress, int index, ChainType chainType, ChainNet network) {
    final networkType = _getNetwork(chainType, network);

    final path = derivePath(account, isChangeAddress, index);

    final hdSeed = bip32.BIP32.fromSeed(seed, networkType);
    final xMasterPriv = bip32.BIP32.fromSeed(hdSeed.privateKey, networkType);
    final keyPair = ECPair.fromPrivateKey(xMasterPriv.derivePath(path).privateKey, network: getNetworkType(chainType, network));

    return keyPair;
  }

  static Future<String> _getPublicAddress(bip32.BIP32 keyPair, ChainType chainType, ChainNet network) async {
    final net = getNetworkType(chainType, network);
    final address = P2SH(data: PaymentData(redeem: P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: net).data), network: net).data.address;

    return address;
  }

  static Future<String> _getPublicAddressFromKeyPair(ECPair keyPair, ChainType chainType, ChainNet network) async {
    final net = getNetworkType(chainType, network);
    final address = P2SH(data: PaymentData(redeem: P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: net).data), network: net).data.address;

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

  static int getDecimalPlaces(ChainType type) {
    return 9;
  }

  static Future<TransactionBuilder> buildAddPollLiquidityTransaction(
      List<tx.Transaction> inputTxs,
      List<FromAccount> authAddressesA,
      List<FromAccount> authAddressesB,
      IWalletDatabase database,
      int tokenA,
      int tokenB,
      String shareAddress,
      int amountA,
      int amountB,
      int fee,
      String returnAddress,
      Uint8List seed,
      ChainType chain,
      ChainNet net) async {
    var network = getNetworkType(chain, net);

    assert(authAddressesA.length == authAddressesB.length);

    final txb = TransactionBuilder(network: network);
    txb.setVersion(2);
    txb.setLockTime(0);

    int totalInputValue = 0;
    for (final tx in inputTxs) {
      txb.addInput(tx.mintTxId, tx.mintIndex);
      totalInputValue += tx.valueRaw;
    }
    int i = 0;
    for (final auth in authAddressesA) {
      var authA = auth;
      var authB = authAddressesB[i];
      txb.addAddLiquidityOutput(tokenA, authA.address, authA.amount, tokenB, authB.address, authB.amount, shareAddress);
    }

    var changeAmount = totalInputValue - fee;
    txb.addOutput(returnAddress, changeAmount);

    int index = 0;

    for (final tx in inputTxs) {
      final addressInfo = await database.getWalletAddress(tx.address);

      final key = HdWalletUtil.getKeyPair(
          seed, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: key.publicKey)).data;
      final redeemScript = p2wpkh.output;
      final pubKey = await _getPublicAddressFromKeyPair(key, chain, net);
      final input = inputTxs[index].mintTxId;
      LogHelper.instance.d("sign tx $input with privateKey from $pubKey");

      txb.sign(vin: index, keyPair: key, witnessValue: inputTxs[index].valueRaw, redeemScript: redeemScript);
      index++;
    }

    final tx = txb.build();
    final txhex = tx.toHex();
    LogHelper.instance.d("txHex is $txhex");
    return txb;
  }

  static Future<TransactionBuilder> buildAccountToAccountTransaction(List<tx.Transaction> inputTxs, List<FromAccount> authAddresses, List<ECPair> keys, int token, String to,
      int amount, int fee, String returnAddress, ChainType chain, ChainNet net) async {
    var network = getNetworkType(chain, net);

    assert(inputTxs.length == keys.length);

    final txb = TransactionBuilder(network: network);
    txb.setVersion(2);
    txb.setLockTime(0);

    int totalInputValue = 0;
    for (final tx in inputTxs) {
      txb.addInput(tx.mintTxId, tx.mintIndex);

      totalInputValue += tx.valueRaw;
    }
    for (final auth in authAddresses) {
      txb.addAccountToAccountOutput(token, auth.address, to, auth.amount);
    }

    var changeAmount = totalInputValue - fee;
    txb.addOutput(returnAddress, changeAmount);

    int index = 0;
    for (final key in keys) {
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: key.publicKey)).data;
      final redeemScript = p2wpkh.output;
      final pubKey = await _getPublicAddressFromKeyPair(key, chain, net);
      final input = inputTxs[index].mintTxId;
      LogHelper.instance.d("sign tx $input with privateKey from $pubKey");

      txb.sign(vin: index, keyPair: key, witnessValue: inputTxs[index].valueRaw, redeemScript: redeemScript);
      index++;
    }

    final tx = txb.build();
    final txhex = tx.toHex();
    LogHelper.instance.d("txHex is $txhex");
    return txb;
  }

  static Future<String> buildTransaction(List<tx.Transaction> inputTxs, List<ECPair> keys, String to, int amount, int fee, String returnAddress,
      Function(TransactionBuilder, List<tx.Transaction>, NetworkType) additional, ChainType chain, ChainNet net) async {
    var network = getNetworkType(chain, net);

    assert(inputTxs.length == keys.length);

    final txb = TransactionBuilder(network: network);
    txb.setVersion(2);
    txb.setLockTime(0);

    int totalInputValue = 0;
    for (final tx in inputTxs) {
      txb.addInput(tx.mintTxId, tx.mintIndex);

      final mintTxId = tx.mintTxId;
      final mintIndex = tx.mintIndex;
      final inValue = tx.value;
      LogHelper.instance.d("set tx input $mintTxId@$mintIndex input value is $inValue");

      totalInputValue += tx.valueRaw;
    }

    if (totalInputValue == amount) {
      throw ArgumentError("$totalInputValue == $amount - inputValue cannot be equal to amount, we need to pay some fees!");
    }

    if (totalInputValue > (amount)) {
      var changeAmount = totalInputValue - amount - fee;
      txb.addOutput(returnAddress, changeAmount);
      LogHelper.instance.d("set tx output (change) $returnAddress value is $changeAmount");
    }
    if (amount > 0) {
      txb.addOutput(to, amount);
      LogHelper.instance.d("set tx output $to value is $amount");
    }

    await additional(txb, inputTxs, network);

    int index = 0;
    for (final key in keys) {
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: key.publicKey)).data;
      final redeemScript = p2wpkh.output;
      final pubKey = await _getPublicAddressFromKeyPair(key, chain, net);
      final input = inputTxs[index].mintTxId;
      final witnessValue = inputTxs[index].valueRaw;
      LogHelper.instance.d("sign tx $input with privateKey from $pubKey witnessValue. $witnessValue");

      txb.sign(vin: index, keyPair: key, witnessValue: witnessValue, redeemScript: redeemScript);
      index++;
    }

    return txb.build().toHex();
  }

  static Future<String> buildAccountToUtxosTransaction(List<tx.Transaction> inputTxs, List<ECPair> keys, String to, int amount, int fee, String returnAddress,
      Function(TransactionBuilder, NetworkType) additional, ChainType chain, ChainNet net) async {
    var network = getNetworkType(chain, net);

    assert(inputTxs.length == keys.length);

    final txb = TransactionBuilder(network: network);
    txb.setVersion(2);
    txb.setLockTime(0);

    int totalInputValue = 0;
    for (final tx in inputTxs) {
      txb.addInput(tx.mintTxId, tx.mintIndex);

      final mintTxId = tx.mintTxId;
      final mintIndex = tx.mintIndex;
      final inValue = tx.value;
      LogHelper.instance.d("set tx input $mintTxId@$mintIndex input value is $inValue");

      totalInputValue += tx.valueRaw;
    }

    if (totalInputValue > (amount)) {
      var changeAmount = totalInputValue - amount - fee;
      txb.addOutput(returnAddress, changeAmount);
      LogHelper.instance.d("set tx output (change) $returnAddress value is $changeAmount");
    }
    if (amount > 0) {
      txb.addOutput(to, amount);
      LogHelper.instance.d("set tx output $to value is $amount");
    }

    additional(txb, network);

    int index = 0;
    for (final key in keys) {
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: key.publicKey)).data;
      final redeemScript = p2wpkh.output;
      final pubKey = await _getPublicAddressFromKeyPair(key, chain, net);
      final input = inputTxs[index].mintTxId;
      final witnessValue = inputTxs[index].valueRaw;
      LogHelper.instance.d("sign tx $input with privateKey from $pubKey witnessValue. $witnessValue");

      txb.sign(vin: index, keyPair: key, witnessValue: witnessValue, redeemScript: redeemScript);
      index++;
    }

    return txb.build().toHex();
  }

  static Future<String> derivePublicKey(Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network) async {
    return await getPublicKey(seed, account, changeAddress, index, chainType, network);
  }

  static Future<List<String>> derivePublicKeys(Uint8List seed, int account, bool changeAddress, int index, ChainType chainType, ChainNet network, int count) async {
    final list = List<String>.empty(growable: true);
    print("derivePublicKey");
    for (int i = 0; i < count; i++) {
      final key = await derivePublicKey(seed, account, changeAddress, index + i, chainType, network);
      list.add(key);
    }
    print("derivePublicKey...done");
    return list;
  }

  static Future<List<String>> derivePublicKeysWithChange(Uint8List seed, int account, int index, ChainType chainType, ChainNet network, int count) async {
    final list = List<String>.empty(growable: true);
    print("derivePublicKeysWithChange");
    for (int i = 0; i < count; i++) {
      final key = await derivePublicKey(seed, account, false, index + i, chainType, network);
      list.add(key);
    }
    for (int i = 0; i < count; i++) {
      final changeKey = await derivePublicKey(seed, account, true, index + i, chainType, network);
      list.add(changeKey);
    }
    print("derivePublicKeyderivePublicKeysWithChangedone");
    return list;
  }

  static String derivePath(int account, bool changeAddress, int index) {
    return "m/$account'/${changeAddress ? 1 : 0}'/$index'";
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

  static List<String> derivePaths(int account, bool changeAddress, int index, int count) {
    final list = List<String>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, changeAddress, index + i));
    }
    return list;
  }

  static List<String> derivePathsWithChange(int account, int index, int count) {
    final list = List<String>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, false, index + i));
    }
    for (int i = 0; i < count; i++) {
      list.add(derivePath(account, true, index + i));
    }
    return list;
  }
}
