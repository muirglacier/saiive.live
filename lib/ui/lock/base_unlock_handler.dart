import 'dart:convert';
import 'package:pointycastle/digests/sha256.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:sqflite/utils/utils.dart';

abstract class BaseUnlockHandler implements IUnlockHandler {
  static const PIN_LENGTH = 4;

  String hashPassword(var input) {
    final sha256 = SHA256Digest();
    final hash = sha256.process(utf8.encode(input));
    final digest = hex(hash);
    return digest;
  }

  @override
  Future<bool> hasUnlockScreenEnabled() async {
    final hash = await sl.get<ISharedPrefsUtil>().getPasswordHash();
    final lockEnabled = hash != null && hash.isNotEmpty;

    return lockEnabled;
  }

  Future<bool> isValid(String input) async {
    final digest = hashPassword(input);
    final savedHash = await sl.get<ISharedPrefsUtil>().getPasswordHash();
    return digest == savedHash;
  }
}
