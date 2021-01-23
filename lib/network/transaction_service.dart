import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/network/model/transaction.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/addresses_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class TransactionService extends NetworkService
{
  Future<List<Transaction>> getAddressTransaction(String coin, String address) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/txs/$address');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();
  }

  Future<List<Transaction>> getAddressesTransactions(String coin, List<String> addresses) async {
    AddressesRequest request = AddressesRequest(addresses: addresses);
    dynamic response = await this.httpService.makeHttpPostRequest('/$coin/txs', request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();
  }

  Future<Transaction> getWithTxId(String coin, String txId) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tx/id/$txId');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return Transaction.fromJson(response);
  }

  Future<Transaction> getBlockTransactions(String coin, String blockId) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tx/block/$blockId');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();
  }

  Future<Transaction> getTransactionsHeight(String coin, int height) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/tx/height/$height');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return json
        .decode(response.body)
        .map<Transaction>((data) => Transaction.fromJson(data))
        .toList();
  }
}