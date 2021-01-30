import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/transaction_loaded_event.dart';
import 'package:defichainwallet/bus/transactions_loaded_event.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/request/raw_tx_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class TransactionService extends NetworkService {
  Future<List<Transaction>> getAddressTransaction(
      String coin, String address) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/txs/$address', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getAddressesTransactions(
      String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response =
        await this.httpService.makeHttpPostRequest('/txs', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getUnspentTransactionOutputs(
      String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response =
        await this.httpService.makeHttpPostRequest('/unspent', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<Transaction> getWithTxId(String coin, String txId) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/tx/id/$txId', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Transaction transaction = Transaction.fromJson(response);

    this.fireEvent(new TransactionLoadedEvent(transaction: transaction));

    return transaction;
  }

  Future<List<Transaction>> getBlockTransactions(
      String coin, String blockId) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/tx/block/$blockId', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<List<Transaction>> getTransactionsHeight(
      String coin, int height) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/tx/height/$height', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<Transaction> transactions = json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();

    this.fireEvent(new TransactionsLoadedEvent(transactions: transactions));

    return transactions;
  }

  Future<String> sendRawTransaction(String coin, String rawTxHex) async {
    final request = RawTxRequest(rawTx: rawTxHex);
    dynamic response =
        await this.httpService.makeHttpPostRequest('/tx/raw', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    final decodedBody = json.decode(response.body);
    return decodedBody["txId"];
  }
}
