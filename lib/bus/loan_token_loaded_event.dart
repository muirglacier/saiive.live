import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/network/model/loan_token.dart';

class LoanTokenLoadedEvent implements Event {
  final LoanToken loanToken;

  LoanTokenLoadedEvent({this.loanToken});
}
