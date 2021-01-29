import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/crypto/hd_wallet_util.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/wallet-sync.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

void main() {
  group("test hd", () {
    setupServiceLocator();
    FlutterConfig.loadValueForTesting(
        {'API_URL': 'https://dev-supernode.defichain-wallet.com'});
    test("get transaction", () async {
      var mnemonic =
          'sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow';
      final apiService = ApiService();
      var seed = mnemonicToSeedHex(mnemonic);

      var wallet = new WalletAccount(account: 0, chain: ChainType.DeFiChain);
      var transaction = await WalletSync.syncTransactions(ChainType.DeFiChain,
          ChainNet.Testnet, mnemonic, "", apiService, [wallet]);
      var unspentTxs = transaction.where((element) => element.spentHeight < 0);

      var unspentTx = unspentTxs.first;

      var networkType =
          HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Testnet);

      final alice = HdWalletUtil.getKeyPair(HEX.decode(seed), unspentTx.account,
          false, unspentTx.index, ChainType.DeFiChain, ChainNet.Testnet);
      final p2wpkh = P2WPKH(data: PaymentData(pubkey: alice.publicKey)).data;
      final redeemScript = p2wpkh.output;

      final txb = TransactionBuilder(network: networkType);
      txb.setVersion(1);
      txb.addInput(unspentTx.mintTxId, 0);
      txb.addOutput('tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN', 10);

      txb.sign(
          vin: 0,
          keyPair: alice,
          redeemScript: redeemScript,
          witnessValue: 80000);
      final txhex = txb.build().toHex();

      debugPrint("test");
    });
  });
}
