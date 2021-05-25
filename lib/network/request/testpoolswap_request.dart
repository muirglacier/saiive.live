import 'package:saiive.live/network/base_request.dart';

class TestPoolSwapRequest extends BaseRequest {
  String from;
  String tokenFrom;
  double amountFrom;
  String to;
  String tokenTo;

  TestPoolSwapRequest({this.from, this.tokenFrom, this.amountFrom, this.to, this.tokenTo});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'from': this.from, 'tokenFrom': this.tokenFrom, 'amountFrom': this.amountFrom, 'to': this.to, 'tokenTo': this.tokenTo};
}
