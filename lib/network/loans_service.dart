import 'dart:async';
import 'dart:convert';

import 'package:saiive.live/bus/loan_collateral_loaded_event.dart';
import 'package:saiive.live/bus/loan_collaterals_loaded_event.dart';
import 'package:saiive.live/bus/loan_schema_loaded_event.dart';
import 'package:saiive.live/bus/loan_schemas_loaded_event.dart';
import 'package:saiive.live/bus/loan_token_loaded_event.dart';
import 'package:saiive.live/bus/loan_tokens_loaded_event.dart';
import 'package:saiive.live/network/model/loan_collateral.dart';
import 'package:saiive.live/network/model/loan_schema.dart';
import 'package:saiive.live/network/model/loan_token.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:saiive.live/network/response/error_response.dart';

abstract class ILoansService {
  Future<List<LoanSchema>> getLoanSchemas(String coin);
  Future<LoanSchema> getSchema(String coin, String schemaId);

  Future<List<LoanCollateral>> getLoanCollaterals(String coin);
  Future<LoanCollateral> getLoanCollateral(String coin, String id);

  Future<List<LoanToken>> getLoanTokens(String coin);
  Future<LoanToken> getLoanToken(String coin, String id);
}

class LoansService extends NetworkService implements ILoansService {
  Future<List<LoanSchema>> getLoanSchemas(String coin) async {
    dynamic response =
        await this.httpService.makeDynamicHttpGetRequest('/loans/schemes', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanSchema> schemas = json.decode(response.body).map<LoanSchema>((data) => LoanSchema.fromJson(data)).toList();

    this.fireEvent(new LoanSchemasLoadedEvent(loanSchemas: schemas));

    return schemas;
  }

  Future<LoanSchema> getSchema(String coin, String schemaId) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/loans/schemes/$schemaId', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    LoanSchema schema = LoanSchema.fromJson(response);

    this.fireEvent(new LoanSchemaLoadedEvent(loanSchema: schema));

    return schema;
  }

  Future<List<LoanCollateral>> getLoanCollaterals(String coin) async {
    dynamic response =
    await this.httpService.makeDynamicHttpGetRequest('/loans/collaterals', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanCollateral> collaterals = json.decode(response.body).map<LoanCollateral>((data) => LoanCollateral.fromJson(data)).toList();

    this.fireEvent(new LoanCollateralsLoadedEvent(loanCollaterals: collaterals));

    return collaterals;
  }

  Future<LoanCollateral> getLoanCollateral(String coin, String id) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/loans/collaterals/$id', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    LoanCollateral collateral = LoanCollateral.fromJson(response);

    this.fireEvent(new LoanCollateralLoadedEvent(loanCollateral: collateral));

    return collateral;
  }

  Future<List<LoanToken>> getLoanTokens(String coin) async {
    dynamic response =
    await this.httpService.makeDynamicHttpGetRequest('/loans/tokens', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<LoanToken> tokens = json.decode(response.body).map<LoanToken>((data) => LoanToken.fromJson(data)).toList();

    this.fireEvent(new LoanTokensLoadedEvent(loanTokens: tokens));

    return tokens;
  }

  Future<LoanToken> getLoanToken(String coin, String id) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/loans/tokens/$id', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    LoanToken token = LoanToken.fromJson(response);

    this.fireEvent(new LoanTokenLoadedEvent(loanToken: token));

    return token;
  }
}
