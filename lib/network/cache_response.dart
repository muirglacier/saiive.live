import 'dart:convert';
import 'package:defichainwallet/network/response/error_response.dart';
import 'package:defichainwallet/service_locator.dart';

import 'package:event_taxi/event_taxi.dart';

import 'ihttp_service.dart';

class CachedResponse
{
  int lifetime;
  int created;
  dynamic data;

  CachedResponse(this.lifetime, this.created, this.data);
}