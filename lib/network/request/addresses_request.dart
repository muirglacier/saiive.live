import 'package:defichainwallet/network/base_request.dart';

class AddressesRequest extends BaseRequest {
  List<String> addresses;

  AddressesRequest({
    this.addresses
  });

  factory AddressesRequest.fromJson(Map<String, dynamic> json) {
    return AddressesRequest(
      addresses: json['addresses']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    <String, dynamic>{
      'addresses': this.addresses
    };
  }
}