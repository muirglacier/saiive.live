import 'dart:async';

import 'package:defichainwallet/model/block.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class BlockService extends NetworkService
{
  Future<Block> getBlockWithHeight(String coin, int height) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/block/$height');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return Block.fromJson(response);
  }

  Future<Block> getBlockTip(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/$coin/block/tip');

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return Block.fromJson(response);
  }

}