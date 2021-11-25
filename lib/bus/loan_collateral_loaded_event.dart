import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:event_taxi/event_taxi.dart';

class LoanCollateralLoadedEvent implements Event {
  final LoanCollateral loanCollateral;

  LoanCollateralLoadedEvent({this.loanCollateral});
}
