import 'package:saiive.live/helper/env.dart';
import 'package:saiive.live/network/model/ivault.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/services/aes_crypto.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopVault extends IVault {
  @override
  Future reEncryptData(String oldPassword, String newPassword) async {
    if (newPassword == null || newPassword.isEmpty) {
      throw new ArgumentError("newPassword cannot be empty!");
    }

    await _reEncrypt(IVault.seedKey, oldPassword, newPassword);
  }

  Future _reEncrypt(String key, String oldPassword, String newPassword) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var currentEnvironment = EnvHelper.getEnvironment();

    String value;
    if (oldPassword == null || oldPassword.isEmpty) {
      value = sharedPreferences.getString(EnvHelper.environmentToString(currentEnvironment) + "_" + key);
      sharedPreferences.remove(EnvHelper.environmentToString(currentEnvironment) + "_" + key);
    } else {
      var encryptedValue = sharedPreferences.getString(EnvHelper.environmentToString(currentEnvironment) + "_enc_" + key);

      value = AesCrypto.decryptAESCryptoJS(encryptedValue, oldPassword);
    }
    if (value == null || value.isEmpty) {
      return value;
    }

    final encrypted = AesCrypto.encryptAESCryptoJS(value, newPassword);
    sharedPreferences.setString(EnvHelper.environmentToString(currentEnvironment) + "_enc_" + key, encrypted);
  }

  Future<String> _write(String key, String value) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var currentEnvironment = EnvHelper.getEnvironment();
    var unlock = sl.get<IUnlockHandler>();

    if (value == null) {
      await sharedPreferences.remove(EnvHelper.environmentToString(currentEnvironment) + "_" + key);
      await sharedPreferences.remove(EnvHelper.environmentToString(currentEnvironment) + "_enc_" + key);
    } else {
      final hash = await sl.get<SharedPrefsUtil>().getPasswordHash();
      final lockEnabled = hash != null && hash.isNotEmpty;

      if (lockEnabled) {
        var unlockCode = await unlock.getUnlockCode();
        final encrypted = AesCrypto.encryptAESCryptoJS(value, unlockCode);
        await sharedPreferences.setString(EnvHelper.environmentToString(currentEnvironment) + "_enc_" + key, encrypted);
      } else {
        await sharedPreferences.setString(EnvHelper.environmentToString(currentEnvironment) + "_" + key, value);
      }
    }

    return value;
  }

  Future<String> _read(String key, {String defaultValue}) async {
    var unlock = sl.get<IUnlockHandler>();
    var sharedPreferences = await SharedPreferences.getInstance();
    var currentEnvironment = EnvHelper.getEnvironment();

    final hash = await sl.get<SharedPrefsUtil>().getPasswordHash();
    final lockEnabled = hash != null && hash.isNotEmpty;

    if (lockEnabled) {
      var value = sharedPreferences.getString(EnvHelper.environmentToString(currentEnvironment) + "_enc_" + key) ?? defaultValue;
      if (value == null || value.isEmpty) {
        return value;
      }

      var unlockCode = await unlock.getUnlockCode();
      final decryptedText = AesCrypto.decryptAESCryptoJS(value, unlockCode);

      return decryptedText;
    }
    var value = sharedPreferences.getString(EnvHelper.environmentToString(currentEnvironment) + "_" + key) ?? defaultValue;
    return value;
  }

  @override
  Future deleteAll() async {
    await _write(IVault.seedKey, null);
  }

  @override
  Future<String> getSeed() async {
    return await _read(IVault.seedKey);
  }

  @override
  Future<String> setSeed(String seed) async {
    return await _write(IVault.seedKey, seed);
  }

  @override
  Future<String> getPrivateKey(String id) async {
    return await _read(IVault.privateKey + id);
  }

  @override
  Future setPrivateKey(String id, String privateKey) async {
    return await _write(IVault.privateKey + id, privateKey);
  }
}
