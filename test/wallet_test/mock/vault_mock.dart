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
  Future<String> getPasswordHash() {
    // TODO: implement getPasswordHash
    throw UnimplementedError();
  }

  @override
  Future setPasswordHash(String hash) {
    // TODO: implement setPasswordHash
    throw UnimplementedError();
  }
}
