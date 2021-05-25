import 'package:saiive.live/network/base_request.dart';

class RawTxRequest extends BaseRequest {
  final String rawTx;

  RawTxRequest({this.rawTx});

  factory RawTxRequest.fromJson(Map<String, dynamic> json) {
    return RawTxRequest(rawTx: json['rawTx']);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'rawTx': this.rawTx};
}
