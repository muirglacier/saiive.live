class ErrorResponse {
  String error;

  ErrorResponse({String error}) {
    this.error = error;
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'],
    );
  }
}