class LoanSchema {
  final String id;
  final String minColRatio;
  final String interestRate;

  LoanSchema({this.id, this.minColRatio, this.interestRate});

  factory LoanSchema.fromJson(Map<String, dynamic> json) {
    return LoanSchema(
        id: json['id'],
        minColRatio: json['minColRatio'],
        interestRate: json['interestRate']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'minColRatio': minColRatio,
        'interestRate': interestRate
      };
}
