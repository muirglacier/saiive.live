import 'package:defichaindart/defichaindart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("defi tests", () {
    test("address test", () {
      var privateKeyWif =
          "cNpueJjp8geQJut28fDyUD8e5zoyctHxj9GE8rTbQXwiEwLo1kq4";
      var keyPair = ECPair.fromWIF(privateKeyWif, network: defichain_testnet);
      final address = P2PKH(
              data: PaymentData(pubkey: keyPair.publicKey),
              network: defichain_testnet)
          .data
          .address;

      expect("769pd87UohNtRVmo1NWewejJGvyKdynt9m", address);
    });
  });
}
