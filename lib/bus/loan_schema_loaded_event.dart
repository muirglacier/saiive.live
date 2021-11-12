import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:event_taxi/event_taxi.dart';

class LoanSchemaLoadedEvent implements Event {
  final LoanSchema loanSchema;

  LoanSchemaLoadedEvent({this.loanSchema});
}
