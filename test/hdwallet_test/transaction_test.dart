import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("test hd", () {
    test("get transaction", () async {
      var network = HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Testnet);

      final alice = ECPair.fromWIF("cNpueJjp8geQJut28fDyUD8e5zoyctHxj9GE8rTbQXwiEwLo1kq4", network: network);

      final p2wpkh = P2WPKH(data: PaymentData(pubkey: alice.publicKey)).data;
      final redeemScript = p2wpkh.output;

      final txb = TransactionBuilder(network: network);
      txb.setVersion(2);
      txb.setLockTime(0);

      txb.addInput('eca1a534a6e9349a77d914b9e593492a9cac58ff9e974aaf5e2353909df367af', 0);
      txb.addOutput('tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN', 27999796096 - 200);

      txb.sign(vin: 0, keyPair: alice, witnessValue: 27999796096, redeemScript: redeemScript);
      final tx = txb.build();
      final txhex = tx.toHex();
      expect(txhex,
          "02000000000101af67f39d9053235eaf4a979eff58ac9c2a4993e5b914d9779a34e9a634a5a1ec000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff01b8faea840600000017a91438f4a35256ea1afcf989eb28bcdfcc082157ac7987024830450221009102f2f177590e96c4e6f9e5269f3fadff98a6b9a2d2fc157666a12926c4b8fa022014620215f6ec933593069962d6f27c5215b013be3bfcc0aea12c8b9011f77e0e012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
    });

    test("get transaction v4", () async {
      var network = HdWalletUtil.getNetworkType(ChainType.DeFiChain, ChainNet.Testnet);

      final alice = ECPair.fromWIF("cNpueJjp8geQJut28fDyUD8e5zoyctHxj9GE8rTbQXwiEwLo1kq4", network: network);

      final p2wpkh = P2WPKH(data: PaymentData(pubkey: alice.publicKey)).data;
      final redeemScript = p2wpkh.output;

      final txb = TransactionBuilder(network: network);
      txb.setVersion(4);
      txb.setLockTime(0);

      txb.addInput('eca1a534a6e9349a77d914b9e593492a9cac58ff9e974aaf5e2353909df367af', 0);
      txb.addOutput('tbTMwPQAtLUYCxHjPRc9upUmHBdGFr8cKN', 27999796096 - 200);

      txb.sign(vin: 0, keyPair: alice, witnessValue: 27999796096, redeemScript: redeemScript);
      final tx = txb.build();
      final txhex = tx.toHex();
      expect(txhex,
          "04000000000101af67f39d9053235eaf4a979eff58ac9c2a4993e5b914d9779a34e9a634a5a1ec000000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff01b8faea840600000017a91438f4a35256ea1afcf989eb28bcdfcc082157ac7987000247304402203d11471c06884a68fd7959590e9ab2058864d4d2763b3b9fc69893d2fb2edbcb022016faee2f844e0a8b462dabe21ff9e6290c33d493787a01bd26329c7a41b1b334012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c00000000");
    });
  });
}
