import 'package:flutter/foundation.dart';
import 'package:saiive.live/crypto/chain.dart';

class AddressBookEntry {
  String name;
  String publicKey;
  final ChainType chain;
  final String id;

  get uniqueId => id;

  AddressBookEntry({@required this.id, @required this.publicKey, @required this.name, @required this.chain});

  factory AddressBookEntry.fromJson(Map<String, dynamic> json) {
    return AddressBookEntry(
      id: json['id'],
      publicKey: json['publicKey'],
      name: json.containsKey("name") ? json["name"] : "",
      chain: json.containsKey("chain") ? ChainType.values[json['chain']] : ChainType.DeFiChain,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'publicKey': publicKey,
        'name': name,
        'chain': chain.index,
      };
}
