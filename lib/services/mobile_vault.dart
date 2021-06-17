import 'package:saiive.live/network/model/ivault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileVault extends IVault {
  final FlutterSecureStorage secureStorage = new FlutterSecureStorage();

  Future<String> _write(String key, String value) async {
    await secureStorage.write(key: key, value: value);

    return value;
  }

  Future<String> _read(String key, {String defaultValue}) async {
    return await secureStorage.read(key: key) ?? defaultValue;
  }

  @override
  Future deleteAll() async {
    return await secureStorage.deleteAll();
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
  Future reEncryptData(String oldPassword, String newPassword) async {}
}
