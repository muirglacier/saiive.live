import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:saiive.live/bus/loan_collateral_loaded_event.dart';
import 'package:saiive.live/bus/loan_collaterals_loaded_event.dart';
import 'package:saiive.live/bus/loan_schema_loaded_event.dart';
import 'package:saiive.live/bus/loan_schemas_loaded_event.dart';
import 'package:saiive.live/bus/loan_token_loaded_event.dart';
import 'package:saiive.live/bus/loan_tokens_loaded_event.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/model/loan_vault_auction.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class ILoansAuctionsService {
  Future<List<LoanVaultAuction>> getAuctions(String coin);
}

class LoansAuctionsService extends NetworkService
    implements ILoansAuctionsService {
  Future<List<LoanVaultAuction>> getAuctions(String coin) async {
    /*dynamic response = await this
        .httpService
        .makeDynamicHttpGetRequest('/loans/auctions', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }*/

    var jsonValue = await rootBundle.loadString('assets/demo/auctions.json');

    List<LoanVaultAuction> auctions = json
        //.decode(response.body)
        .decode(jsonValue)
        .map<LoanVaultAuction>((data) => LoanVaultAuction.fromJson(data))
        .toList();

    return auctions;
  }
}
