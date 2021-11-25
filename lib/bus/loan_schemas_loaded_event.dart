import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:event_taxi/event_taxi.dart';

class LoanSchemasLoadedEvent implements Event {
  final List<LoanSchema> loanSchemas;

  LoanSchemasLoadedEvent({this.loanSchemas});
}
