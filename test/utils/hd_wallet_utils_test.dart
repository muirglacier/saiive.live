import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';

void main() async {
  group("HD Wallet Utils test", () {
    test("test BIP32 path generation", () {
      expect(HdWalletUtil.derivePath(10, true, 100, DerivationPathType.BIP32), "m/10'/1'/100'");
      expect(HdWalletUtil.derivePath(10, false, 100, DerivationPathType.BIP32), "m/10'/0'/100'");
      expect(HdWalletUtil.derivePath(0, true, 69, DerivationPathType.BIP32), "m/0'/1'/69'");
      expect(HdWalletUtil.derivePath(0, false, 1, DerivationPathType.BIP32), "m/0'/0'/1'");
    });
    test("test FullNodeWallet path generation", () {
      expect(HdWalletUtil.derivePath(10, true, 100, DerivationPathType.FullNodeWallet), "m/10'/1'/100'");
      expect(HdWalletUtil.derivePath(10, false, 100, DerivationPathType.FullNodeWallet), "m/10'/0'/100'");
      expect(HdWalletUtil.derivePath(0, true, 69, DerivationPathType.FullNodeWallet), "m/0'/1'/69'");
      expect(HdWalletUtil.derivePath(0, false, 1, DerivationPathType.FullNodeWallet), "m/0'/0'/1'");
    });
    test("test BIP44 path generation", () {
      expect(HdWalletUtil.derivePath(10, true, 100, DerivationPathType.BIP44), "m/44'/1129'/10'/1'/100'");
      expect(HdWalletUtil.derivePath(10, false, 100, DerivationPathType.BIP44), "m/44'/1129'/10'/0'/100'");
      expect(HdWalletUtil.derivePath(0, true, 69, DerivationPathType.BIP44), "m/44'/1129'/0'/1'/69'");
      expect(HdWalletUtil.derivePath(0, false, 1, DerivationPathType.BIP44), "m/44'/1129'/0'/0'/1'");
    });
    test("test Jellyfish bullshit path generation", () {
      expect(HdWalletUtil.derivePath(10, true, 100, DerivationPathType.JellyfishBullshit), "1129/10/1/100");
      expect(HdWalletUtil.derivePath(10, false, 100, DerivationPathType.JellyfishBullshit), "1129/10/0/100");
      expect(HdWalletUtil.derivePath(0, true, 69, DerivationPathType.JellyfishBullshit), "1129/0/1/69");
      expect(HdWalletUtil.derivePath(0, false, 1, DerivationPathType.JellyfishBullshit), "1129/0/0/1");
    });
    test("test BIP32 path isChangeAddress", () {
      expect(HdWalletUtil.isPathChangeAddress("m/10'/1'/100'"), true);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/1'/69'"), true);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/0'/0'"), false);
      expect(HdWalletUtil.isPathChangeAddress("m/0'/0'/1'"), false);
    });
    test("test BIP32 path getIndexFromPath", () {
      expect(HdWalletUtil.getIndexFromPath("m/10'/1'/100'"), 100);
      expect(HdWalletUtil.getIndexFromPath("m/0'/1'/69'"), 69);
      expect(HdWalletUtil.getIndexFromPath("m/0'/0'/0'"), 0);
      expect(HdWalletUtil.getIndexFromPath("m/0'/0'/1'"), 1);
    });
  });
}
