import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group("HD Wallet Utils test", () {
    test("test BIP39 path generation", () {
      expect(HdWalletUtil.derivePath(10, true, 100), "m/10'/1'/100'");
      expect(HdWalletUtil.derivePath(10, false, 100), "m/10'/0'/100'");
      expect(HdWalletUtil.derivePath(0, true, 69), "m/0'/1'/69'");
      expect(HdWalletUtil.derivePath(0, false, 1), "m/0'/0'/1'");
    });
    test("test BIP39 path isChangeAddress", () {
      expect(HdWalletUtil.isPathChangeAddress("m/10'/1'/100'"), true);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/1'/69'"), true);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/0'/0'"), false);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/0'/1'"), false);
    });
    test("test BIP39 path getIndexFromPath", () {
      expect(HdWalletUtil.getIndexFromPath("m/10'/1'/100'"), 100);
      expect(HdWalletUtil.getIndexFromPath("m/0'/1'/69'"), 69);
      expect(HdWalletUtil.getIndexFromPath("m/0'/0'/0'"), 0);
      expect(HdWalletUtil.getIndexFromPath("m/0'/0'/1'"), 1);
    });
  });
}
