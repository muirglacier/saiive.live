import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/lock/unlock_handler.dart';


class AuthenticationHelper {
  Future forceAuth(context, onAuth()) async {
    var unlockHandler = sl.get<IUnlockHandler>();

    var unlocked = await unlockHandler.unlockScreen(context);

    if (unlocked) {
      await onAuth();
    }
  }
}
