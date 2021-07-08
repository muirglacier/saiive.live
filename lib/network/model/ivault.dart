abstract class IVault {
  static const String seedKey = 'defichainwallet_seed';
  static const String encryptionKey = 'defichainwallet_secret_phrase';
  static const String privateKey = 'saiive_private_key_';
  static const String passwordHashKey = 'defichainwallet_password_hash';

  Future<String> getSeed();
  Future setSeed(String seed);

  Future<String> getPrivateKey(String id);
  Future setPrivateKey(String id, String privateKey);

  Future deleteAll();

  Future reEncryptData(String oldPassword, String newPassword);
}
