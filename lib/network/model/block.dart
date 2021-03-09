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
      nonce: BigInt.from(json['nonce']),
      bits: BigInt.from(json['bits']),
      previousBlockHash: json['previousBlockHash'],
      nextBlockHash: json['nextBlockHash'],
      reward: double.tryParse(json['reward'].toString()),
      transactionCount: json['transactionCount'],
      confirmations: json['confirmations'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'chain': chain,
    'network': network,
    'hash': hash,
    'size': size,
    'height': height,
    'merkleRoot': merkleRoot,
    'time': time,
    'nonce': nonce,
    'bits': bits,
    'previousBlockHash': previousBlockHash,
    'nextBlockHash': nextBlockHash,
    'reward': reward,
    'transactionCount': transactionCount,
    'confirmations': confirmations
  };
}
