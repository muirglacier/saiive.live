import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/transaction_service.dart';

class TransactionServiceMock implements ITransactionService {
  String lastTx;
  List<String> txs = List<String>.empty(growable: true);

  @override
  Future<List<Transaction>> getAddressTransaction(String coin, String address) {
    return null;
  }

  @override
  Future<List<Transaction>> getAddressesTransactions(String coin, List<String> addresses) {
    return null;
  }

  @override
  Future<List<Transaction>> getUnspentTransactionOutputs(String coin, List<String> addresses) {
    return null;
  }

  @override
  Future<TransactionData> getWithTxId(String coin, String txId) async {
    return new TransactionData(details: TransactionDetail(inputs: List<Transaction>.empty(), outputs: List<Transaction>.empty()));
  }

  @override
  Future<String> sendRawTransaction(String coin, String rawTxHex) async {
    txs.add(rawTxHex);
    lastTx = rawTxHex;
    return rawTxHex;
  }
}
