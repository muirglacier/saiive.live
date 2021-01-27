import 'package:defichainwallet/network/model/transaction.dart';
import 'package:event_taxi/event_taxi.dart';

class TransactionsLoadedEvent implements Event {
  final List<Transaction> transactions;

  TransactionsLoadedEvent({this.transactions});
}