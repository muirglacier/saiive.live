import 'package:saiive.live/ui/model/available_themes.dart';
import 'package:saiive.live/ui/model/available_language.dart';
import 'package:saiive.live/ui/model/authentication_method.dart';
import 'package:saiive.live/network/model/block.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';

class SharedPrefsMock extends ISharedPrefsUtil {
  @override
  Future<void> deleteAll() async {}

  @override
  Future<int> getAddressIndex(String walletId, bool isChangeAddress) {
    return Future.value(0);
  }

  @override
  Future<AuthenticationMethod> getAuthMethod() {
    return Future.value(AuthenticationMethod(AuthMethod.NONE));
  }

  @override
  Future<ChainNet> getChainNetwork() {
    return Future.value(ChainNet.Testnet);
  }

  @override
  Future<bool> getFirstLaunch() {
    return Future.value(false);
  }

  @override
  Future<String> getInstanceId() {
    return Future.value("test");
  }

  @override
  Future<LanguageSetting> getLanguage() {
    return Future.value(LanguageSetting(AvailableLanguage.ENGLISH));
  }

  @override
  Future<Block> getLastSyncedBlock() {
    return Future.value(null);
  }

  @override
  Future<String> getPasswordHash() {
    return Future.value(null);
  }

  @override
  String getRandString(int len) {
    return "null";
  }

  @override
  Future<bool> getSeedBackedUp() {
    return Future.value(false);
  }

  @override
  Future<bool> getShowTestModePage() {
    return Future.value(false);
  }

  @override
  Future<ThemeSetting> getTheme() {
    return Future.value(ThemeSetting(ThemeOptions.DEFI_DARK));
  }

  @override
  Future<bool> hasLastSyncedBlock() {
    return Future.value(false);
  }

  @override
  Future<void> resetInstanceId() async {}

  @override
  Future<void> setAddressIndex(String walletId, int index, bool isChangeAddress) async {}

  @override
  Future<void> setFirstLaunch() async {}

  @override
  Future<void> setLanguage(LanguageSetting language) async {}

  @override
  Future<void> setLastSyncedBlock(Block block) async {}

  @override
  Future<void> setNetwork(ChainNet network) async {}

  @override
  Future<void> setPasswordHash(String hash) async {}

  @override
  Future<void> setSeedBackedUp(bool value) async {}

  @override
  Future<void> setTheme(ThemeSetting theme) async {}

  @override
  Future setUseAuthentiaction(AuthMethod method) async {}

  @override
  Future<int> getMaxAddressCount() {
    return Future.value(40);
  }

  @override
  Future<bool> getUseSingleAddressWallet() {
    return Future.value(false);
  }

  @override
  Future setMaxAddressCount(int value) async {}

  @override
  Future setUseSingleAddressWallet(bool value) async {}
}
