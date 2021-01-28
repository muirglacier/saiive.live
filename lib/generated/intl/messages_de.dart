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
    "home_welcome_account_synced" : MessageLookupByLibrary.simpleMessage("Deine %s Konten sind aktualisiert!"),
    "home_welcome_account_syncing" : MessageLookupByLibrary.simpleMessage("Aktualisieren..."),
    "home_welcome_good_day" : MessageLookupByLibrary.simpleMessage("Guten Tag"),
    "home_welcome_good_evening" : MessageLookupByLibrary.simpleMessage("Guten Abend"),
    "home_welcome_good_morning" : MessageLookupByLibrary.simpleMessage("Guten Tag"),
    "later" : MessageLookupByLibrary.simpleMessage("Später"),
    "loading" : MessageLookupByLibrary.simpleMessage("Laden..."),
    "next" : MessageLookupByLibrary.simpleMessage("Weiter"),
    "receive" : MessageLookupByLibrary.simpleMessage("Empfangen"),
    "send" : MessageLookupByLibrary.simpleMessage("Senden"),
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "title" : MessageLookupByLibrary.simpleMessage("DeFiChain Wallet"),
    "version" : MessageLookupByLibrary.simpleMessage("Version"),
    "wallet_empty" : MessageLookupByLibrary.simpleMessage("Dein Wallet ist leer!"),
    "wallet_new_info1_header" : MessageLookupByLibrary.simpleMessage("Was sind Wiederherstellungswörter?"),
    "wallet_new_info1_text" : MessageLookupByLibrary.simpleMessage("Es ist dein Master Private Key für dein Wallet, sozusagen Benutzername und Kennwort. Nur du solltest Zugriff darauf haben, gib acht!"),
    "wallet_new_info2_header" : MessageLookupByLibrary.simpleMessage("Für was brauch ich diese?"),
    "wallet_new_info2_text" : MessageLookupByLibrary.simpleMessage("Du kannst diese nutzen um dein Wallet auf einem anderen Gerät wiederherzustellen. Wenn du diese verlierst, wirst du nie wieder Zugriff auf deine Assets haben, wir speichert keine Kopie davon!"),
    "wallet_new_info3_header" : MessageLookupByLibrary.simpleMessage("Wo sollte ich diese aufbewahren?"),
    "wallet_new_info3_text" : MessageLookupByLibrary.simpleMessage("Am besten du schreibst es auf und bewahrst es in einem Offline Storage. Mach keinen Screenshot davon, da dies Hackbar ist!"),
    "wallet_new_info4_header" : MessageLookupByLibrary.simpleMessage("Lass uns starten!"),
    "wallet_new_info4_text" : MessageLookupByLibrary.simpleMessage("Deine Wiederherstellungswörter werden im nächsten Schritt als 24 Wörter gezeigt."),
    "wallet_new_info5_header" : MessageLookupByLibrary.simpleMessage("Familien Konto?"),
    "wallet_new_info5_text" : MessageLookupByLibrary.simpleMessage("Du kannst deine Wiederherstellungswörter mit Personen in deinem Haushalt teilen um ein gemeinsames Haushaltskonto zu führen!"),
    "wallet_new_phrase_info" : MessageLookupByLibrary.simpleMessage("Das sind deine Wiederherstellungswörter. Schreibe sie auf, und verliere sie nicht!"),
    "wallet_new_reveal" : MessageLookupByLibrary.simpleMessage("Zeig meine Wiederherstellungswörter"),
    "wallet_new_test_confirm" : MessageLookupByLibrary.simpleMessage("Bestätige deine Wiederherstellungswörter"),
    "wallet_new_test_invalid" : MessageLookupByLibrary.simpleMessage("Ungültiges Wort"),
    "wallet_new_test_put1" : MessageLookupByLibrary.simpleMessage("Schreibe das #"),
    "wallet_new_test_put2" : MessageLookupByLibrary.simpleMessage(" Wort hier"),
    "wallet_new_test_word" : MessageLookupByLibrary.simpleMessage(" Wort"),
    "wallet_recovery_phrase_test_title" : MessageLookupByLibrary.simpleMessage("Wiederherstellungswörter Test"),
    "wallet_recovery_phrase_title" : MessageLookupByLibrary.simpleMessage("Wiederherstellungswörter"),
    "wallet_restore_accountsAdded" : MessageLookupByLibrary.simpleMessage("Wir haben die Kontos in deinem lokalen Datestore hinzugefügt! Deine Konten werden im Hintergrund aktualisiert!"),
    "wallet_restore_accountsFound" : MessageLookupByLibrary.simpleMessage("Wir haben die folgenden Kontos gefunden:"),
    "wallet_restore_enterMnemonic" : MessageLookupByLibrary.simpleMessage("Gib deinen Wiederherstellungssatz ein!"),
    "wallet_restore_enterWords" : MessageLookupByLibrary.simpleMessage("Wiederherstellungswörter eingeben"),
    "wallet_restore_invalidMnemonic" : MessageLookupByLibrary.simpleMessage("Der Wiederherstellungsastz ist ungültig."),
    "wallet_restore_loading" : MessageLookupByLibrary.simpleMessage("Wallet wiederherstellung, dies kann einige Zeit dauern!"),
    "wallet_restore_noAccountFound" : MessageLookupByLibrary.simpleMessage("Wir konnten kein Konto finden, wir haben eines für dich angelegt!"),
    "wallet_restore_not_safed" : MessageLookupByLibrary.simpleMessage("Du hast deine Wiederherstellungswörter noch nicht gesichert, willst du das jetzt machen?"),
    "wallet_restore_recoveryPhrase" : MessageLookupByLibrary.simpleMessage("Wiederherstellungswörter"),
    "wallet_token_available_balance" : MessageLookupByLibrary.simpleMessage("Verfügbar"),
    "wallet_token_transactions" : MessageLookupByLibrary.simpleMessage("Transaktionen"),
    "welcome" : MessageLookupByLibrary.simpleMessage("Willkommen"),
    "welcome_wallet_create" : MessageLookupByLibrary.simpleMessage("Neues Wallet anlegen"),
    "welcome_wallet_info" : MessageLookupByLibrary.simpleMessage("Erstelle dein DeFiChain Wallet und behalte die Kontrolle der Privaten Schlüssel!"),
    "welcome_wallet_privacy" : MessageLookupByLibrary.simpleMessage("Deine Privaten Schlüssel werden lokal verschlüsselt abgelegt und verwaltet, geschützt durch deine Biometrie/PIN."),
    "welcome_wallet_restore" : MessageLookupByLibrary.simpleMessage("Wallet importieren"),
    "welcome_wallet_secure" : MessageLookupByLibrary.simpleMessage("Sicher")
  };
}
