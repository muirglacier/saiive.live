import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:event_taxi/event_taxi.dart';

class LoanCollateralsLoadedEvent implements Event {
  final List<LoanCollateral> loanCollaterals;

  LoanCollateralsLoadedEvent({this.loanCollaterals});
}
