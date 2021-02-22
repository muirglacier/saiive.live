import 'base_request.dart';

abstract class IHttpService {
  Future init();
  Future<Map<String, dynamic>> makeHttpGetRequest(String url, String coin, {cached: false});
  Future<dynamic> makeDynamicHttpGetRequest(String url, String coin, {cached: false});
  Future<dynamic> makeHttpPostRequest(String url, String coin, BaseRequest request);
}
