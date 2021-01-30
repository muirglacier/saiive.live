abstract class IVault {
  Future<String> getSeed();

  Future deleteAll();

  Future setSeed(String seed);
}