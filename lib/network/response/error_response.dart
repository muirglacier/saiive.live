import 'package:http/http.dart';

class ErrorResponse {
  String error;
  Response response;

  ErrorResponse({String error, Response response}) {
    this.error = error;
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'],
    );
  }
}
