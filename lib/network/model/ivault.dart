abstract class IVault {
  static const String seedKey = 'defichainwallet_seed';
  static const String encryptionKey = 'defichainwallet_secret_phrase';

  static const String passwordHashKey = 'defichainwallet_password_hash';

  Future<String> getSeed();
  Future setSeed(String seed);

  Future deleteAll();

  Future reEncryptData(String oldPassword, String newPassword);
}
