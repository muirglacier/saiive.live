import 'package:defichainwallet/network/base_request.dart';
import 'package:defichainwallet/network/ihttp_service.dart';

class MockHttpService extends IHttpService {
  @override
  Future init() {
    return Future.delayed(Duration(microseconds: 1));
  }

  @override
  Future<Map<String, dynamic>> makeHttpGetRequest(
      String url, String coin, {cached: false}) async {
    await Future.delayed(Duration(microseconds: 1));
    return null;
  }

  @override
  Future<Map<String, dynamic>> makeDynamicHttpGetRequest(
      String url, String coin, {cached: false}) async {
    await Future.delayed(Duration(microseconds: 1));
    return null;
  }

  @override
  Future makeHttpPostRequest(
      String url, String coin, BaseRequest request) async {
    await Future.delayed(Duration(microseconds: 1));
    return null;
  }
}
