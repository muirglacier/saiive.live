import 'package:saiive.live/network/events/base/base_error_event.dart';

class WalletInitDoneEvent extends BaseErrorEvent {
  WalletInitDoneEvent({bool hasError = false, Error error}) : super(hasError: hasError, error: error);
}
