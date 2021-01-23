class Block {
  final String id;
  final String chain;
  final String network;
  final String hash;
  final int size;
  final int height;
  final String merkleRoot;
  final String time;
  final BigInt nonce;
  final BigInt bits;
  final String previousBlockHash;
  final String nextBlockHash;
  final double reward;
  final int transactionCount;
  final int confirmations;

  Block({
    this.id,
    this.chain,
    this.network,
    this.hash,
    this.size,
    this.height,
    this.merkleRoot,
    this.time,
    this.nonce,
    this.bits,
    this.previousBlockHash,
    this.nextBlockHash,
    this.reward,
    this.transactionCount,
    this.confirmations,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      chain: json['chain:'],
      network: json['network'],
      hash: json['hash'],
      size: json['size'],
      height: json['height'],
      merkleRoot: json['merkleRoot'],
      time: json['time'],
      nonce: json['nonce'],
      bits: json['bits'],
      previousBlockHash: json['previousBlockHash'],
      nextBlockHash: json['nextBlockHash'],
      reward: json['reward'],
      transactionCount: json['transactionCount'],
      confirmations: json['confirmations'],
    );
  }
}
