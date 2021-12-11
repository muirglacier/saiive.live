import 'package:saiive.live/crypto/chain.dart';

class Stats {
  final StatsCount count;

  Stats({this.count});

  int eunosHeight(ChainNet net) {
    if (net == ChainNet.Testnet) {
      return 354950;
    }
    return 894000;
  }

  double dexRewards (ChainNet chainNet) {
    return (blockSubsidy(chainNet) * 0.2545);
  }

  double tokenRewards (ChainNet chainNet) {
    return (blockSubsidy(chainNet) * 0.2468);
  }

  double blockSubsidy (ChainNet chainNet) {
    var blockSubsidy = 405.04;
    var _eunosHeight = eunosHeight(chainNet);

    if (count.blocks >= _eunosHeight) {
      var reductionAmount = 0.01658;
      var reductions = ((count.blocks - _eunosHeight) / 32690).floor();

      for (var i = reductions; i > 0; i--) {
        var amount = reductionAmount * blockSubsidy;

        if (amount < 0.00001) {
          return 0;
        }

        blockSubsidy = blockSubsidy - amount;
      }
    }

    return blockSubsidy;
  }

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
