import 'dart:convert' as utf;
import 'dart:io';

import 'package:defichainwallet/network/model/ivault.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vault extends IVault {
  static const String seedKey = 'defichainwallet_seed';
  static const String encryptionKey = 'defichainwallet_secret_phrase';

  final FlutterSecureStorage secureStorage = new FlutterSecureStorage();

  // Re-usable
  Future<String> _write(String key, String value) async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      var sharedPreferences = await SharedPreferences.getInstance();

      if (value == null) {
        sharedPreferences.remove(key);
      } else {
        sharedPreferences.setString(key, value);
      }
    } else {
      await secureStorage.write(key: key, value: value);
    }
    return value;
  }

  Future<String> _read(String key, {String defaultValue}) async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      var sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences.getString(key) ?? defaultValue;
    } else {
      return await secureStorage.read(key: key) ?? defaultValue;
    }
  }

  Future deleteAll() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return await Future.delayed(Duration(milliseconds: 1));
    } else {
      return await secureStorage.deleteAll();
    }
  }

  // Specific keys
  Future<String> getSeed() async {
    return await _read(seedKey);
  }

  // Specific keys
  Future<String> getSeedHash() async {
    var seed = await _read(seedKey);
    if (seed == null || seed.isEmpty) {
      return "";
    }
    var utf8 = utf.utf8.encode(seed);
    var value = sha256.convert(utf8).toString();

    return value;
  }

  Future<String> setSeed(String seed) async {
    return await _write(seedKey, seed);
  }

  Future<void> deleteSeed() async {
    return await secureStorage.delete(key: seedKey);
  }

  Future<String> getEncryptionPhrase() async {
    return await _read(encryptionKey);
  }

  Future<String> writeEncryptionPhrase(String secret) async {
    return await _write(encryptionKey, secret);
  }

  Future<void> deleteEncryptionPhrase() async {
    return await secureStorage.delete(key: encryptionKey);
  }

  static const _channel = const MethodChannel('fappchannel');

  Future<String> getSecret() async {
    return await _channel.invokeMethod('getSecret');
  }
}
