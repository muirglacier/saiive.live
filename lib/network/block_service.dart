import 'dart:async';

import 'package:defichainwallet/bus/block_loaded_event.dart';
import 'package:defichainwallet/network/model/block.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class BlockService extends NetworkService {
  Future<Block> getBlockWithHeight(String coin, int height) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/block/$height', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Block block = Block.fromJson(response);

    this.fireEvent(new BlockLoadedEvent(block: block));

    return block;
  }

  Future<Block> getBlockTip(String coin) async {
    dynamic response = await this.httpService.makeHttpGetRequest('/block/tip', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    Block block = Block.fromJson(response);

    this.fireEvent(new BlockLoadedEvent(block: block));

    return block;
  }
}
