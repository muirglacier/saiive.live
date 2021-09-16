import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:saiive.live/helper/poolpair.dart';
import 'package:saiive.live/helper/poolshare.dart';
import 'package:saiive.live/network/model/account_balance.dart';
import 'package:saiive.live/network/model/pool_pair_liquidity.dart';
import 'package:saiive.live/network/model/pool_share_liquidity.dart';

class ChannelConnection {
  final channel = MethodChannel('at.saiive.live');

  Future<void> init() async {
    await channel.setMethodCallHandler((call) async {
      // Receive data from Native
      switch (call.method) {
        case "loadLiquidity":
          var liquidity = await new PoolShareHelper().getMyPoolShares('DFI', 'USD');
          var poolPairLiquidity = await new PoolPairHelper().getPoolPairs('DFI', 'USD');

          sendLiquidity(liquidity);
          sendPoolPairs(poolPairLiquidity);
          break;
        default:
          break;
      }
    });
  }

  void sendBalance(List<AccountBalance> balance) async {
    sendData({"method": "receiveBalance", "data": jsonEncode(balance)});
  }

  void sendLiquidity(List<PoolShareLiquidity> poolShares) {
    sendData({"method": "receivePoolShares", "data": jsonEncode(poolShares)});
  }

  void sendPoolPairs(List<PoolPairLiquidity> poolPairs) {
    sendData({"method": "receivePoolPairs", "data": jsonEncode(poolPairs)});
  }

  void sendPublicKeysDFI(List<String> addresses) {
    sendMessage({"method": "receivePublicKeysDFI", "data": jsonEncode(addresses)});
  }

  void sendPublicKeysBTC(List<String> addresses) {
    sendMessage({"method": "receivePublicKeysBTC", "data": jsonEncode(addresses)});
  }

  void sendMessage(var data) {
    print("----- sending to watch");
    print(data);

    channel.invokeMethod("message", data);
  }

  void sendData(var data) {
    print("----- sending to watch");
    print(data);

    channel.invokeMethod("applicationContext", data);
  }
}