import 'dart:convert';
import 'dart:math';

import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/network/model/block.dart';
import 'package:saiive.live/ui/model/authentication_method.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saiive.live/ui/model/available_language.dart';
import 'package:saiive.live/ui/model/available_themes.dart';

class SharedPrefsUtil {
  // Keys
  static const String first_launch_key = 'saiive_first_launch';
  static const String seed_backed_up_key = 'saiive_seed_backup';
  static const String cur_language = 'saiive_language_pref';
  static const String cur_theme = 'saiive_theme_pref';
  static const String cur_net = 'cur_net';
  static const String auth_method = 'saiive_auth_method';
  static const String last_block = 'saiive_defichain_last_block';
  static const String last_block_btc = 'saiive_btc_last_block';
  static const String test_mode_page = 'test_mode_page';
  static const String instance_id = 'instance_id';
  static const String change_address_index = 'chg_addr_index';
  static const String address_index = 'addr_index';

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
    } else if (value == null) {
      sharedPreferences.remove(key);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key) ?? defaultValue;
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

  Future<void> setAddressIndex(int index, bool isChangeAddress) async {
    return await set(isChangeAddress ? change_address_index : address_index, index);
  }

  Future<int> getAddressIndex(bool isChangeAddress) async {
    var curIndex = await get(isChangeAddress ? change_address_index : address_index, defaultValue: 0);

    await setAddressIndex(curIndex + 1, isChangeAddress);

    return curIndex;
  }

  Future<void> resetInstanceId() async {
    return await set(instance_id, null);
  }

  Future<String> getInstanceId() async {
    final rand = getRandString(10);
    final value = await get(instance_id, defaultValue: null);

    if (value == null) {
      await set(instance_id, rand);
      return rand;
    }
    return value;
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  Future<bool> getShowTestModePage() async {
    return await get(test_mode_page, defaultValue: true);
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
    ChainNet defaultNetwork = ChainNet.Testnet;
    try {
      final defaultNetworkString = env["DEFAULT_NETWORK"];
      defaultNetwork = ChainHelper.networkFromString(defaultNetworkString);
    } catch (e) {
      //ignore
    }

    return ChainNet.values[await get(cur_net, defaultValue: defaultNetwork.index)];
  }

  // For logging out
  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(seed_backed_up_key);
  }
}
