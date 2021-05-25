import 'dart:async';
import 'dart:convert';
import 'package:saiive.live/bus/transactions_loaded_event.dart';
import 'package:saiive.live/network/model/transaction.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/request/addresses_request.dart';
import 'package:saiive.live/network/request/raw_tx_request.dart';
import 'package:saiive.live/network/response/error_response.dart';

import 'model/transaction_data.dart';

abstract class ITransactionService {
  Future<List<Transaction>> getAddressTransaction(String coin, String address);
  Future<List<Transaction>> getAddressesTransactions(String coin, List<String> addresses);
  Future<List<Transaction>> getUnspentTransactionOutputs(String coin, List<String> addresses);
  Future<TransactionData> getWithTxId(String coin, String txId);
}

class TransactionService extends NetworkService implements ITransactionService {
  Future<List<Transaction>> getAddressTransaction(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/txs/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json.decode(response.body).map<Transaction>((data) => Transaction.fromJson(data)).toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getAddressesTransactions(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/txs', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final transactions = await transactionsFromJson(response);
    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getUnspentTransactionOutputs(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/unspent', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final transactions = await transactionsFromJson(response);

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<TransactionData> getWithTxId(String coin, String txId) async {
    dynamic response = await this.httpService.makeDynamicHttpGetRequest('/tx/id/$txId', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }
    Map decoded = json.decode(response.body);
    final transaction = TransactionData.fromJson(decoded);
    transaction.txId = txId;
    return transaction;
  }

  Future<List<Transaction>> getBlockTransactions(String coin, String blockId) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/tx/block/$blockId', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json.decode(response.body).map<Transaction>((data) => Transaction.fromJson(data)).toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getTransactionsHeight(String coin, int height) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/tx/height/$height', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json.decode(response.body).map<Transaction>((data) => Transaction.fromJson(data)).toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<String> sendRawTransaction(String coin, String rawTxHex) async {
    final request = RawTxRequest(rawTx: rawTxHex);
    dynamic response = await this.httpService.makeHttpPostRequest('/tx/raw', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final decodedBody = json.decode(response.body);
    return decodedBody["txId"];
  }
}
