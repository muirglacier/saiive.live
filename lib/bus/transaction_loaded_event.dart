import 'package:defichainwallet/network/model/transaction.dart';
import 'package:event_taxi/event_taxi.dart';

class TransactionLoadedEvent implements Event {
  final Transaction transaction;

  TransactionLoadedEvent({this.transaction});
}