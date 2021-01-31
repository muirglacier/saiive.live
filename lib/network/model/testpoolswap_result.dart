class TestPoolSwapResult {
  final String result;

  TestPoolSwapResult({
    this.result,
  });

  factory TestPoolSwapResult.fromJson(Map<String, dynamic> json) {
    return TestPoolSwapResult(
      result: json['result'],
    );
  }
}
