import 'package:http/http.dart';

class ErrorResponse implements Exception {
  String error;
  Response response;

  ErrorResponse({String error, Response response}) {
    this.error = error;
  }

  @override
  String toString() {
    return error;
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'],
    );
  }
}
