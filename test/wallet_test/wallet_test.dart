import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wallet_test_base.dart';

void main() async {
  setupTestServiceLocator();

  await sl.allReady();

  group("wallet tests", () {
    test("test create tx", () async {
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.init();

     
      final tx = await wallet.createSendTransaction(
          1000000000, "\$DFI", "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");

      expect(tx, "020000000001027183420ff39067699eac9ec3b22d9e6a5466c3bf31b50a32fa73f04e47df6ac0010000001716001421cf7b9e2e17fa2879be2a442d8454219236bd3affffffff27278e5cbc857433ffc08bdeaa7e5d563011b756715024cf20d978ec7fa05dd80000000017160014faf5b246f4ed8fe5b9e149a036404aa2c2ea451bffffffff02402b50490600000017a9146015a95984366c654bbd6ab55edab391ff8d747f8700ca9a3b0000000017a9141084ef98bacfecbc9f140496b26516ae55d79bfa8702473044022067acb386b138ad7ff894c5fbbe6e91e3a3e1bd153861fd244000982ff9a5e6ba02204d1061e89ede5f525583eef7846d95a98b92f5f0629388f4824da01d7a591421012103352705381be729d234e692a6ee4bf9e2800b9fc1ef0ebc96b6cf35c38658c93c0248304502210080d217aae754611d4ba5f577b832beabf4f78f263b9614fc941b184eee392f6802201e7041e8b2eadbe07b37d13d233432b80c2a27ec0590576e3e6f1ec1e4adef8201210241e3f9c894cd6d44c6a262d442f7aaf92e41c1dd6eb118334e7c5742335c8bcc00000000");
      debugPrint(tx);
    });
  });
}
