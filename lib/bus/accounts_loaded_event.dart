import 'package:defichainwallet/network/model/account.dart';
import 'package:event_taxi/event_taxi.dart';

class AccountsLoadedEvent implements Event {
  final List<Account> accounts;

  AccountsLoadedEvent({this.accounts});
}