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

  static m0(chains) => "Es scheint gerade Probleme mit dem Supernode zu geben (${chains}). Am besten du schaust später nochmal rein!";

  static m1(from, to) => "Aktualisiere Adressen (${from}/${to})";

  static m2(from, to) => "Aktualisiere Transaktionen (${from}/${to})";

  static m3(coin) => "Sende nur ${coin} an diese Adresse. Wenn du einen anderen Coin als ${coin} an diese Adresse sendest, kann das zum Verlust deiner Einzahlung führen!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "biometric_auth_error" : MessageLookupByLibrary.simpleMessage("Biometric Authentification Error"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "dark_mode" : MessageLookupByLibrary.simpleMessage("Dunkel"),
    "dex" : MessageLookupByLibrary.simpleMessage("DEX"),
    "dex_add_max" : MessageLookupByLibrary.simpleMessage("max"),
    "dex_amount" : MessageLookupByLibrary.simpleMessage("Erhaltender Betrag"),
    "dex_commission" : MessageLookupByLibrary.simpleMessage("Komission"),
    "dex_from_amount" : MessageLookupByLibrary.simpleMessage("Menge Von"),
    "dex_from_token" : MessageLookupByLibrary.simpleMessage("Von Token"),
    "dex_insufficient_funds" : MessageLookupByLibrary.simpleMessage("Nicht genügend Balance für Tausch."),
    "dex_price" : MessageLookupByLibrary.simpleMessage("Preis"),
    "dex_swap" : MessageLookupByLibrary.simpleMessage("Swap"),
    "dex_swap_show_transaction" : MessageLookupByLibrary.simpleMessage("Im Explorer"),
    "dex_swap_successfull" : MessageLookupByLibrary.simpleMessage("Swap erfolgreich"),
    "dex_to_amount" : MessageLookupByLibrary.simpleMessage("Menge Auf"),
    "dex_to_token" : MessageLookupByLibrary.simpleMessage("Auf Token"),
    "helloWorld" : MessageLookupByLibrary.simpleMessage("Hallo Welt!"),
    "home_dex" : MessageLookupByLibrary.simpleMessage("DEX"),
    "home_liquidity" : MessageLookupByLibrary.simpleMessage("Liquidity"),
    "home_tokens" : MessageLookupByLibrary.simpleMessage("Tokens"),
    "home_wallet" : MessageLookupByLibrary.simpleMessage("Wallet"),
    "home_welcome_account_block_height" : MessageLookupByLibrary.simpleMessage("Block Höhe: "),
    "home_welcome_account_synced" : MessageLookupByLibrary.simpleMessage("Wallet ist aktualisiert..."),
    "home_welcome_account_syncing" : MessageLookupByLibrary.simpleMessage("Aktualisieren..."),
    "home_welcome_good_day" : MessageLookupByLibrary.simpleMessage("Guten Tag"),
    "home_welcome_good_evening" : MessageLookupByLibrary.simpleMessage("Guten Abend"),
    "home_welcome_good_morning" : MessageLookupByLibrary.simpleMessage("Guten Tag"),
    "later" : MessageLookupByLibrary.simpleMessage("Später"),
    "light_mode" : MessageLookupByLibrary.simpleMessage("Hell"),
    "liqudity_add_successfull" : MessageLookupByLibrary.simpleMessage("Hinzufügen war erfolgreich"),
    "liqudity_pool_pairs" : MessageLookupByLibrary.simpleMessage("Pool Paare"),
    "liqudity_your_liquidity" : MessageLookupByLibrary.simpleMessage("Deine Liquidität"),
    "liquidity" : MessageLookupByLibrary.simpleMessage("Liquidity"),
    "liquidity_add" : MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "liquidity_add_amount_a" : MessageLookupByLibrary.simpleMessage("Amount A"),
    "liquidity_add_amount_b" : MessageLookupByLibrary.simpleMessage("Amount B"),
    "liquidity_add_insufficient_funds" : MessageLookupByLibrary.simpleMessage("Nicht genügend Balance für LM"),
    "liquidity_add_max" : MessageLookupByLibrary.simpleMessage("max"),
    "liquidity_add_pool_share" : MessageLookupByLibrary.simpleMessage("Pool Share"),
    "liquidity_add_price" : MessageLookupByLibrary.simpleMessage("Preis"),
    "liquidity_add_token_a" : MessageLookupByLibrary.simpleMessage("Token A"),
    "liquidity_add_token_b" : MessageLookupByLibrary.simpleMessage("Token B"),
    "liquidity_add_total_pooled" : MessageLookupByLibrary.simpleMessage("Insgesammt gepoolt"),
    "liquidity_pool_share_percentage" : MessageLookupByLibrary.simpleMessage("Pool-Anteil"),
    "liquidity_remove" : MessageLookupByLibrary.simpleMessage("Entfernen"),
    "liquidity_remove_of" : MessageLookupByLibrary.simpleMessage("von"),
    "liquidity_remove_price" : MessageLookupByLibrary.simpleMessage("Preis"),
    "liquidity_remove_successfull" : MessageLookupByLibrary.simpleMessage("Entfernen war erfolgreich"),
    "loading" : MessageLookupByLibrary.simpleMessage("Laden..."),
    "next" : MessageLookupByLibrary.simpleMessage("Weiter"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "receive" : MessageLookupByLibrary.simpleMessage("Empfangen"),
    "receive_address_copied_to_clipboard" : MessageLookupByLibrary.simpleMessage("Adresse wurde in die Zwischenablage übernommen"),
    "send" : MessageLookupByLibrary.simpleMessage("Senden"),
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_auth_biometric" : MessageLookupByLibrary.simpleMessage("Biometrisch"),
    "settings_auth_none" : MessageLookupByLibrary.simpleMessage("Keine"),
    "settings_change_network_text" : MessageLookupByLibrary.simpleMessage("Bist du sicher ins \"Mainnet\" zu wechseln? Du bist allein für deine Funds verantwortlich!"),
    "settings_change_network_title" : MessageLookupByLibrary.simpleMessage("Achtung!"),
    "settings_disclaimer" : MessageLookupByLibrary.simpleMessage("No one who is contributing to this project is taking any responsibility of what happens to your funds."),
    "settings_donate" : MessageLookupByLibrary.simpleMessage("Wenn du uns helfen willst die App noch besser machen, kannst du uns gerne DFI spenden:"),
    "settings_network_changed" : MessageLookupByLibrary.simpleMessage("Netzwerk wurde geändert..."),
    "settings_remove_seed" : MessageLookupByLibrary.simpleMessage("Seed löschen"),
    "settings_removed_seed" : MessageLookupByLibrary.simpleMessage("Seed gelöscht"),
    "settings_show_seed" : MessageLookupByLibrary.simpleMessage("Seed anzeigen"),
    "test_info" : MessageLookupByLibrary.simpleMessage("Danke fürs Testen!"),
    "test_info_epilogue" : MessageLookupByLibrary.simpleMessage("Die App hat sicherlich noch einige Bugs, solltest du einen Fehler bei einer Transaktion bekommen, teste es einfach nochmal! Vergiss bitte nicht einen Issue auf GitHub anzulegen. Du kannst auch alle PublicKeys auf der Settings Seite kopieren!"),
    "test_info_feedback" : MessageLookupByLibrary.simpleMessage("Möchtest du uns feedback geben, oder hast einen Bug gefunden, leg bitte einen Issue bei GitHub an:"),
    "test_info_funds" : MessageLookupByLibrary.simpleMessage("Wir bitten dich im testnet zu bleiben. Du bekommst von uns gerne Funds zum testen. Für dies haben wir ein Forumlar erstellt welches du hier findest:"),
    "test_info_telegram" : MessageLookupByLibrary.simpleMessage("Für fragen haben wir eine Telegram Gruppe erstellt, diese findest du hier:"),
    "test_info_test" : MessageLookupByLibrary.simpleMessage("Danke für deine Hilfe das saiive.live für alle verfügbar zu machen. Dein Feedback hilft uns sehr!"),
    "title" : MessageLookupByLibrary.simpleMessage("saiive.live"),
    "version" : MessageLookupByLibrary.simpleMessage("Version"),
    "wallet_empty" : MessageLookupByLibrary.simpleMessage("Dein Wallet ist leer!"),
    "wallet_home_network" : MessageLookupByLibrary.simpleMessage("Netzwerk"),
    "wallet_locked" : MessageLookupByLibrary.simpleMessage("Wallet synchronisiert gerade!"),
    "wallet_new_creating" : MessageLookupByLibrary.simpleMessage("Wir bereiten dein Wallet vor, dies dauert einige Sekunden."),
    "wallet_new_creating_title" : MessageLookupByLibrary.simpleMessage("Wallet"),
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
    "wallet_offline" : m0,
    "wallet_operation_build_tx" : MessageLookupByLibrary.simpleMessage("Transaktion wird erstellt"),
    "wallet_operation_create_auth_tx" : MessageLookupByLibrary.simpleMessage("Erstelle Auth TX"),
    "wallet_operation_create_pepare_acc_tx" : MessageLookupByLibrary.simpleMessage("Account wird vorbereitet"),
    "wallet_operation_create_swap_tx" : MessageLookupByLibrary.simpleMessage("Swap transaktion wird erstellt"),
    "wallet_operation_mempool_conflict" : MessageLookupByLibrary.simpleMessage("Bitte warte bis deine Transaktion dem nächsten Block hinzugefügt wurde, bevor du mit einer neuen Transaktion fortfährst."),
    "wallet_operation_mempool_conflict_retry" : MessageLookupByLibrary.simpleMessage("Es befinden sich noch Transaktionen in der Warteschlange, wir versuchen auf diese zu Warten, dies kann etwas dauern!"),
    "wallet_operation_missing_inputs" : MessageLookupByLibrary.simpleMessage("Dein Wallet ist nicht mehr synchronisiert. Bitte versuche die Transaktion erneut."),
    "wallet_operation_refresh_addresses" : m1,
    "wallet_operation_refresh_tx" : m2,
    "wallet_operation_refresh_utxo" : MessageLookupByLibrary.simpleMessage("UTXO aktualisieren..."),
    "wallet_operation_refresh_utxo_done" : MessageLookupByLibrary.simpleMessage("UTXO aktualisieren...fertig"),
    "wallet_operation_send_tx" : MessageLookupByLibrary.simpleMessage("Transaktion wird gesendet"),
    "wallet_receive" : MessageLookupByLibrary.simpleMessage("Empfangen"),
    "wallet_receive_warning" : m3,
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
    "wallet_restore_word_empty" : MessageLookupByLibrary.simpleMessage("Bitte Wort eingeben"),
    "wallet_restore_word_hint" : MessageLookupByLibrary.simpleMessage("Wort eingeben"),
    "wallet_restore_word_invalid" : MessageLookupByLibrary.simpleMessage("Wort ist ungültig"),
    "wallet_send" : MessageLookupByLibrary.simpleMessage("Senden"),
    "wallet_send_address" : MessageLookupByLibrary.simpleMessage("Adresse"),
    "wallet_send_address_scan" : MessageLookupByLibrary.simpleMessage("Scan"),
    "wallet_send_amount" : MessageLookupByLibrary.simpleMessage("Menge"),
    "wallet_token_available_balance" : MessageLookupByLibrary.simpleMessage("Verfügbar"),
    "wallet_token_show_in_explorer" : MessageLookupByLibrary.simpleMessage("Im Explorer anzeigen"),
    "wallet_token_transactions" : MessageLookupByLibrary.simpleMessage("Transaktionen"),
    "wallet_uptime_stats" : MessageLookupByLibrary.simpleMessage("Status anzeigen"),
    "welcome" : MessageLookupByLibrary.simpleMessage("Willkommen"),
    "welcome_wallet_create" : MessageLookupByLibrary.simpleMessage("Neues Wallet anlegen"),
    "welcome_wallet_info" : MessageLookupByLibrary.simpleMessage("Erstelle dein DeFiChain Wallet und behalte die Kontrolle deiner Privaten Schlüssel!"),
    "welcome_wallet_privacy" : MessageLookupByLibrary.simpleMessage("Deine Privaten Schlüssel werden lokal verschlüsselt abgelegt und verwaltet, geschützt durch deine Biometrie/PIN."),
    "welcome_wallet_restore" : MessageLookupByLibrary.simpleMessage("Wallet importieren"),
    "welcome_wallet_secure" : MessageLookupByLibrary.simpleMessage("Sicher")
  };
}
