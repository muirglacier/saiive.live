import 'dart:convert';

import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/network/model/block.dart';
import 'package:defichainwallet/ui/model/authentication_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defichainwallet/ui/model/available_language.dart';
import 'package:defichainwallet/ui/model/available_themes.dart';

class SharedPrefsUtil {
  // Keys
  static const String first_launch_key = 'defi_first_launch';
  static const String seed_backed_up_key = 'defi_seed_backup';
  static const String cur_language = 'defi_language_pref';
  static const String cur_theme = 'defi_theme_pref';
  static const String cur_net = 'cur_net';
  static const String auth_method = 'defi_auth_method';
  static const String last_block = 'defi_last_block';

  // For plain-text data
  Future<void> set(String key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.get(key) ?? defaultValue;
  }

  // Key-specific helpers
  Future<void> setSeedBackedUp(bool value) async {
    return await set(seed_backed_up_key, value);
  }

  Future<bool> getSeedBackedUp() async {
    return await get(seed_backed_up_key, defaultValue: false);
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
    return await set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(AuthMethod.values[await get(auth_method, defaultValue: AuthMethod.NONE.index)]);
  }

  Future<void> setFirstLaunch() async {
    return await set(first_launch_key, false);
  }

  Future<bool> getFirstLaunch() async {
    return await get(first_launch_key, defaultValue: true);
  }

  Future<void> setLastSyncedBlock(Block block) async {
    return await set(last_block, block.toJson());
  }

  Future<bool> hasLastSyncedBlock() async {
    return await get(last_block) != null;
  }

  Future<Block> getLastSyncedBlock() async {
    String block = await get(last_block);

    return Block.fromJson(json.decode(block.toString()));
  }

  Future<void> setLanguage(LanguageSetting language) async {
    return await set(cur_language, language.getIndex());
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(AvailableLanguage.values[await get(cur_language, defaultValue: AvailableLanguage.DEFAULT.index)]);
  }

  Future<void> setTheme(ThemeSetting theme) async {
    return await set(cur_theme, theme.getIndex());
  }

  Future<void> setNetwork(ChainNet network) async {
    return await set(cur_net, network.index);
  }

  Future<ThemeSetting> getTheme() async {
    return ThemeSetting(ThemeOptions.values[await get(cur_theme, defaultValue: ThemeOptions.DEFI_LIGHT.index)]);
  }

  Future<ChainNet> getChainNetwork() async {
    return ChainNet.values[await get(cur_net, defaultValue: ChainNet.Testnet.index)];
  }

  // For logging out
  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(seed_backed_up_key);
  }
}
