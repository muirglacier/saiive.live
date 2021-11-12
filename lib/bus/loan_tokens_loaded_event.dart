import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/network/model/loan_token.dart';

class LoanTokensLoadedEvent implements Event {
  final List<LoanToken> loanTokens;

  LoanTokensLoadedEvent({this.loanTokens});
}
