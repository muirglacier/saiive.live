// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "helloWorld" : MessageLookupByLibrary.simpleMessage("Hallo Welt!"),
    "home_dex" : MessageLookupByLibrary.simpleMessage("DEX"),
    "home_liquitiy" : MessageLookupByLibrary.simpleMessage("Liquidity"),
    "home_tokens" : MessageLookupByLibrary.simpleMessage("Tokens"),
    "home_wallet" : MessageLookupByLibrary.simpleMessage("Wallet"),
    "title" : MessageLookupByLibrary.simpleMessage("DeFiChain Wallet"),
    "version" : MessageLookupByLibrary.simpleMessage("Version"),
    "welcome" : MessageLookupByLibrary.simpleMessage("Willkommen"),
    "welcome_wallet_create" : MessageLookupByLibrary.simpleMessage("Neues Wallet anlegen"),
    "welcome_wallet_info" : MessageLookupByLibrary.simpleMessage("Erstelle dein DeFiChain Wallet und behalte die Kontrolle der Privaten Schlüssel!"),
    "welcome_wallet_privacy" : MessageLookupByLibrary.simpleMessage("Deine Privaten Schlüssel werden lokal verschlüsselt abgelegt und verwaltet, geschützt durch deine Biometrie/PIN."),
    "welcome_wallet_restore" : MessageLookupByLibrary.simpleMessage("Wallet importieren"),
    "welcome_wallet_secure" : MessageLookupByLibrary.simpleMessage("Sicher")
  };
}
