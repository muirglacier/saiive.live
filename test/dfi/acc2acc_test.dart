import 'package:bip32/bip32.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("defi tests", () {
    test("address test", () {
      var privateKeyWif =
          "cNpueJjp8geQJut28fDyUD8e5zoyctHxj9GE8rTbQXwiEwLo1kq4";
      var keyPair = ECPair.fromWIF(privateKeyWif, network: defichain_testnet);
     final address =
          P2PKH(data: PaymentData(pubkey: keyPair.publicKey), network: defichain_testnet).data.address;

      expect("", address);
    });
    test("test account 2 account", () {
      //dMq6aiTKWyf2hRiDqcczkd7SE36rchn1kw
      var eicd = ECPair.fromWIF(
          "cPx3xUD441mriaUkA7t3Q4jSen7rHX5Za3942QrBVyCasknqy7YK",
          network: defichain_testnet);

      final address = P2SH(
              data: PaymentData(pubkey: eicd.publicKey),
              network: defichain_testnet)
          .data
          .address;

      final add = address;
    });
  });
}
