import 'package:flutter/cupertino.dart';

class Stats {
  final StatsCount count;

  Stats({this.count});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      count: StatsCount.fromJson(json['count']),
    );
  }
}

class StatsCount {
  final int blocks;

  StatsCount({this.blocks});

  factory StatsCount.fromJson(Map<String, dynamic> json) {
    return StatsCount(
        blocks: json['blocks'],
    );
  }
}
