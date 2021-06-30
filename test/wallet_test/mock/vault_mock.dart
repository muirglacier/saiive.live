import 'package:saiive.live/network/model/ivault.dart';

class VaultMock extends IVault {
  String _seed;

  VaultMock(this._seed);

  @override
  Future deleteAll() async {}

  @override
  Future<String> getSeed() async {
    return _seed;
  }

  @override
  Future setSeed(String seed) async {
    _seed = seed;
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<String> getPasswordHash() {
    throw UnimplementedError();
  }

  @override
  // ignore: override_on_non_overriding_member
  Future setPasswordHash(String hash) {
    throw UnimplementedError();
  }

  @override
  // ignore: override_on_non_overriding_member
  Future reEncryptData(String oldPassword, String newPassword) {
    throw UnimplementedError();
  }
}
