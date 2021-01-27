import 'package:defichainwallet/network/events/base/base_error_event.dart';

class WalletSyncDoneEvent extends BaseErrorEvent {
  WalletSyncDoneEvent({bool hasError = false, Error error})
      : super(hasError: hasError, error: error) {
        
      }
}
