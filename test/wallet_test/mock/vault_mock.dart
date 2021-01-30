import 'package:defichainwallet/network/model/ivault.dart';

class VaultMock extends IVault {
  String _seed =
      "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow";

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
}
