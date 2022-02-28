enum AddressType { Legacy, P2SHSegwit, Bech32 }

String addressTypeToString(AddressType addressType) {
  switch (addressType) {
    case AddressType.Legacy:
      return "Legacy";
    case AddressType.P2SHSegwit:
      return "P2SH";
    case AddressType.Bech32:
      return "bech32";
  }
  throw ArgumentError("unknown");
}
