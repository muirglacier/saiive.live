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

          break;
        default:
          break;
      }
    });
  }

  void sendPublicKeysDFI(List<String> addresses) {
    sendData({"method": "receivePublicKeysDFI", "data": jsonEncode(addresses)});
  }

  void sendPublicKeysBTC(List<String> addresses) {
    sendData({"method": "receivePublicKeysBTC", "data": jsonEncode(addresses)});
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