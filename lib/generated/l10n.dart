// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hello World!`
  String get helloWorld {
    return Intl.message(
      'Hello World!',
      name: 'helloWorld',
      desc: 'The conventional newborn programmer greeting',
      args: [],
    );
  }

  /// `saiive.live`
  String get title {
    return Intl.message(
      'saiive.live',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get home_wallet {
    return Intl.message(
      'Wallet',
      name: 'home_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Liquidity`
  String get home_liquidity {
    return Intl.message(
      'Liquidity',
      name: 'home_liquidity',
      desc: '',
      args: [],
    );
  }

  /// `DEX`
  String get home_dex {
    return Intl.message(
      'DEX',
      name: 'home_dex',
      desc: '',
      args: [],
    );
  }

  /// `DEX V2`
  String get home_dex_v2 {
    return Intl.message(
      'DEX V2',
      name: 'home_dex_v2',
      desc: '',
      args: [],
    );
  }

  /// `Tokens`
  String get home_tokens {
    return Intl.message(
      'Tokens',
      name: 'home_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get later {
    return Intl.message(
      'Later',
      name: 'later',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Label`
  String get label {
    return Intl.message(
      'Label',
      name: 'label',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message(
      'Advanced',
      name: 'advanced',
      desc: '',
      args: [],
    );
  }

  /// `Visibility`
  String get visibility {
    return Intl.message(
      'Visibility',
      name: 'visibility',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get show {
    return Intl.message(
      'Display',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Open in explorer`
  String get show_in_explorer {
    return Intl.message(
      'Open in explorer',
      name: 'show_in_explorer',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark_mode {
    return Intl.message(
      'Dark',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light_mode {
    return Intl.message(
      'Light',
      name: 'light_mode',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for testing!`
  String get test_info {
    return Intl.message(
      'Thanks for testing!',
      name: 'test_info',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for helping us bringing the saiive.live to a bigger audience. Your feedback helps us a lot!`
  String get test_info_test {
    return Intl.message(
      'Thanks for helping us bringing the saiive.live to a bigger audience. Your feedback helps us a lot!',
      name: 'test_info_test',
      desc: '',
      args: [],
    );
  }

  /// `We recomment you staying in the testnet. You will receive some funds from us. We provided a form for that here:`
  String get test_info_funds {
    return Intl.message(
      'We recomment you staying in the testnet. You will receive some funds from us. We provided a form for that here:',
      name: 'test_info_funds',
      desc: '',
      args: [],
    );
  }

  /// `If you have any questions, we have created a Telegram group for that:`
  String get test_info_telegram {
    return Intl.message(
      'If you have any questions, we have created a Telegram group for that:',
      name: 'test_info_telegram',
      desc: '',
      args: [],
    );
  }

  /// `If you want to provide feedback, or found any bugs, please create a GitHub issue here:`
  String get test_info_feedback {
    return Intl.message(
      'If you want to provide feedback, or found any bugs, please create a GitHub issue here:',
      name: 'test_info_feedback',
      desc: '',
      args: [],
    );
  }

  /// `The app has for sure some bugs, if you get an error creating a transaction, just retry it a couple times. Don't forget to create a GitHub issue. You can provide us all your publicKey addresses as well, just copy them from the Settings page!`
  String get test_info_epilogue {
    return Intl.message(
      'The app has for sure some bugs, if you get an error creating a transaction, just retry it a couple times. Don\'t forget to create a GitHub issue. You can provide us all your publicKey addresses as well, just copy them from the Settings page!',
      name: 'test_info_epilogue',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get wallet_home_network {
    return Intl.message(
      'Network',
      name: 'wallet_home_network',
      desc: '',
      args: [],
    );
  }

  /// `It seems we are having some problems with the supernode ({chains}), we are working hard to restore our services. Check back later...`
  String wallet_offline(Object chains) {
    return Intl.message(
      'It seems we are having some problems with the supernode ($chains), we are working hard to restore our services. Check back later...',
      name: 'wallet_offline',
      desc: '',
      args: [chains],
    );
  }

  /// `Show state`
  String get wallet_uptime_stats {
    return Intl.message(
      'Show state',
      name: 'wallet_uptime_stats',
      desc: '',
      args: [],
    );
  }

  /// `Create a new wallet`
  String get welcome_wallet_create {
    return Intl.message(
      'Create a new wallet',
      name: 'welcome_wallet_create',
      desc: '',
      args: [],
    );
  }

  /// `Import existing wallet`
  String get welcome_wallet_restore {
    return Intl.message(
      'Import existing wallet',
      name: 'welcome_wallet_restore',
      desc: '',
      args: [],
    );
  }

  /// `Create your DeFiChain wallet and keep full control of your private keys!`
  String get welcome_wallet_info {
    return Intl.message(
      'Create your DeFiChain wallet and keep full control of your private keys!',
      name: 'welcome_wallet_info',
      desc: '',
      args: [],
    );
  }

  /// `Secure`
  String get welcome_wallet_secure {
    return Intl.message(
      'Secure',
      name: 'welcome_wallet_secure',
      desc: '',
      args: [],
    );
  }

  /// `We care about your privacy! We do not store any data unencrypted. All your private keys are encrypted locally and protected by your biometrics.`
  String get welcome_wallet_privacy {
    return Intl.message(
      'We care about your privacy! We do not store any data unencrypted. All your private keys are encrypted locally and protected by your biometrics.',
      name: 'welcome_wallet_privacy',
      desc: '',
      args: [],
    );
  }

  /// `I've read and accepted the Termns of Service and Privacy Notice`
  String get welcome_accept_terms_and_privacy {
    return Intl.message(
      'I\'ve read and accepted the Termns of Service and Privacy Notice',
      name: 'welcome_accept_terms_and_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Legal`
  String get welcome_legal {
    return Intl.message(
      'Legal',
      name: 'welcome_legal',
      desc: '',
      args: [],
    );
  }

  /// `Please review the saiive.live Terms of Service and Private Notice.`
  String get welcome_legal_text {
    return Intl.message(
      'Please review the saiive.live Terms of Service and Private Notice.',
      name: 'welcome_legal_text',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get welcome_legal_tos {
    return Intl.message(
      'Terms of Service',
      name: 'welcome_legal_tos',
      desc: '',
      args: [],
    );
  }

  /// `Private Notice`
  String get welcome_legal_privacy {
    return Intl.message(
      'Private Notice',
      name: 'welcome_legal_privacy',
      desc: '',
      args: [],
    );
  }

  /// `https://static.saiive.live/tos.html`
  String get welcome_legal_tos_link {
    return Intl.message(
      'https://static.saiive.live/tos.html',
      name: 'welcome_legal_tos_link',
      desc: '',
      args: [],
    );
  }

  /// `https://static.saiive.live/privacy.html`
  String get welcome_legal_privacy_link {
    return Intl.message(
      'https://static.saiive.live/privacy.html',
      name: 'welcome_legal_privacy_link',
      desc: '',
      args: [],
    );
  }

  /// `Reveal my recovery phrase`
  String get wallet_new_reveal {
    return Intl.message(
      'Reveal my recovery phrase',
      name: 'wallet_new_reveal',
      desc: '',
      args: [],
    );
  }

  /// `What's a recovery phrase?`
  String get wallet_new_info1_header {
    return Intl.message(
      'What\'s a recovery phrase?',
      name: 'wallet_new_info1_header',
      desc: '',
      args: [],
    );
  }

  /// `It's the master private key to your wallet and the assets within, only you can access and should take full control of it.`
  String get wallet_new_info1_text {
    return Intl.message(
      'It\'s the master private key to your wallet and the assets within, only you can access and should take full control of it.',
      name: 'wallet_new_info1_text',
      desc: '',
      args: [],
    );
  }

  /// `Why do you need it?`
  String get wallet_new_info2_header {
    return Intl.message(
      'Why do you need it?',
      name: 'wallet_new_info2_header',
      desc: '',
      args: [],
    );
  }

  /// `You can use it to import and recover your wallet on a new device. If you lose it, you will never get your assets back we do not keep a copy!`
  String get wallet_new_info2_text {
    return Intl.message(
      'You can use it to import and recover your wallet on a new device. If you lose it, you will never get your assets back we do not keep a copy!',
      name: 'wallet_new_info2_text',
      desc: '',
      args: [],
    );
  }

  /// `Where should you store it?`
  String get wallet_new_info3_header {
    return Intl.message(
      'Where should you store it?',
      name: 'wallet_new_info3_header',
      desc: '',
      args: [],
    );
  }

  /// `It should be written down and store in a secure offline location. Never take screenshots of it as everything online is hackable!`
  String get wallet_new_info3_text {
    return Intl.message(
      'It should be written down and store in a secure offline location. Never take screenshots of it as everything online is hackable!',
      name: 'wallet_new_info3_text',
      desc: '',
      args: [],
    );
  }

  /// `Let's get started!`
  String get wallet_new_info4_header {
    return Intl.message(
      'Let\'s get started!',
      name: 'wallet_new_info4_header',
      desc: '',
      args: [],
    );
  }

  /// `You recovery phrase will be shown to you in the next screen as a 24-word phrase`
  String get wallet_new_info4_text {
    return Intl.message(
      'You recovery phrase will be shown to you in the next screen as a 24-word phrase',
      name: 'wallet_new_info4_text',
      desc: '',
      args: [],
    );
  }

  /// `Family account?`
  String get wallet_new_info5_header {
    return Intl.message(
      'Family account?',
      name: 'wallet_new_info5_header',
      desc: '',
      args: [],
    );
  }

  /// `You can share your recovery phrase with people in your home!`
  String get wallet_new_info5_text {
    return Intl.message(
      'You can share your recovery phrase with people in your home!',
      name: 'wallet_new_info5_text',
      desc: '',
      args: [],
    );
  }

  /// ` word`
  String get wallet_new_test_word {
    return Intl.message(
      ' word',
      name: 'wallet_new_test_word',
      desc: '',
      args: [],
    );
  }

  /// `Invalid word`
  String get wallet_new_test_invalid {
    return Intl.message(
      'Invalid word',
      name: 'wallet_new_test_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Put the #`
  String get wallet_new_test_put1 {
    return Intl.message(
      'Put the #',
      name: 'wallet_new_test_put1',
      desc: '',
      args: [],
    );
  }

  /// ` word here`
  String get wallet_new_test_put2 {
    return Intl.message(
      ' word here',
      name: 'wallet_new_test_put2',
      desc: '',
      args: [],
    );
  }

  /// `Confirm recovery phrase`
  String get wallet_new_test_confirm {
    return Intl.message(
      'Confirm recovery phrase',
      name: 'wallet_new_test_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Just to make sure that you wrote down the correct words!`
  String get wallet_new_test_confirm_info {
    return Intl.message(
      'Just to make sure that you wrote down the correct words!',
      name: 'wallet_new_test_confirm_info',
      desc: '',
      args: [],
    );
  }

  /// `This is your recovery phrase! Write it down, and do not lose it!`
  String get wallet_new_phrase_info {
    return Intl.message(
      'This is your recovery phrase! Write it down, and do not lose it!',
      name: 'wallet_new_phrase_info',
      desc: '',
      args: [],
    );
  }

  /// `Path derviation type`
  String get wallet_new_phrase_path_derivation_type {
    return Intl.message(
      'Path derviation type',
      name: 'wallet_new_phrase_path_derivation_type',
      desc: '',
      args: [],
    );
  }

  /// `We are preparing your wallet, hang on a second.`
  String get wallet_new_creating {
    return Intl.message(
      'We are preparing your wallet, hang on a second.',
      name: 'wallet_new_creating',
      desc: '',
      args: [],
    );
  }

  /// `Wallet preparing`
  String get wallet_new_creating_title {
    return Intl.message(
      'Wallet preparing',
      name: 'wallet_new_creating_title',
      desc: '',
      args: [],
    );
  }

  /// `Recovery phrase`
  String get wallet_recovery_phrase_title {
    return Intl.message(
      'Recovery phrase',
      name: 'wallet_recovery_phrase_title',
      desc: '',
      args: [],
    );
  }

  /// `Recovery phrase test`
  String get wallet_recovery_phrase_test_title {
    return Intl.message(
      'Recovery phrase test',
      name: 'wallet_recovery_phrase_test_title',
      desc: '',
      args: [],
    );
  }

  /// `Share...`
  String get wallet_operation_share {
    return Intl.message(
      'Share...',
      name: 'wallet_operation_share',
      desc: '',
      args: [],
    );
  }

  /// `Transaction failed :(`
  String get wallet_operation_failed {
    return Intl.message(
      'Transaction failed :(',
      name: 'wallet_operation_failed',
      desc: '',
      args: [],
    );
  }

  /// `No UTXO existing. To create a transaction your wallet needs to have some UTXO!`
  String get wallet_operation_no_utxo {
    return Intl.message(
      'No UTXO existing. To create a transaction your wallet needs to have some UTXO!',
      name: 'wallet_operation_no_utxo',
      desc: '',
      args: [],
    );
  }

  /// `Wait for confirmation...`
  String get wallet_operation_wait_for_confirmation {
    return Intl.message(
      'Wait for confirmation...',
      name: 'wallet_operation_wait_for_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Wait for confirmation {txId}...`
  String wallet_operation_tx_wait_for_confirmation(Object txId) {
    return Intl.message(
      'Wait for confirmation $txId...',
      name: 'wallet_operation_tx_wait_for_confirmation',
      desc: '',
      args: [txId],
    );
  }

  /// `Transaction was successful :)`
  String get wallet_operation_success {
    return Intl.message(
      'Transaction was successful :)',
      name: 'wallet_operation_success',
      desc: '',
      args: [],
    );
  }

  /// `Show transaction in the explorer...`
  String get wallet_operation_show_tx {
    return Intl.message(
      'Show transaction in the explorer...',
      name: 'wallet_operation_show_tx',
      desc: '',
      args: [],
    );
  }

  /// `We did not found a used account, but we have created one for you!`
  String get wallet_restore_noAccountFound {
    return Intl.message(
      'We did not found a used account, but we have created one for you!',
      name: 'wallet_restore_noAccountFound',
      desc: '',
      args: [],
    );
  }

  /// `We have found the following accounts:`
  String get wallet_restore_accountsFound {
    return Intl.message(
      'We have found the following accounts:',
      name: 'wallet_restore_accountsFound',
      desc: '',
      args: [],
    );
  }

  /// `The accounts have been added to your local datastore! Your acounts will be synced in the background!`
  String get wallet_restore_accountsAdded {
    return Intl.message(
      'The accounts have been added to your local datastore! Your acounts will be synced in the background!',
      name: 'wallet_restore_accountsAdded',
      desc: '',
      args: [],
    );
  }

  /// `Restoring your wallet, this can take up some time!`
  String get wallet_restore_loading {
    return Intl.message(
      'Restoring your wallet, this can take up some time!',
      name: 'wallet_restore_loading',
      desc: '',
      args: [],
    );
  }

  /// `Enter your recovery phrase to restore your wallet!`
  String get wallet_restore_enterMnemonic {
    return Intl.message(
      'Enter your recovery phrase to restore your wallet!',
      name: 'wallet_restore_enterMnemonic',
      desc: '',
      args: [],
    );
  }

  /// `The recovery phrase is invalid!`
  String get wallet_restore_invalidMnemonic {
    return Intl.message(
      'The recovery phrase is invalid!',
      name: 'wallet_restore_invalidMnemonic',
      desc: '',
      args: [],
    );
  }

  /// `Selelct phrase words`
  String get wallet_restore_enterWords {
    return Intl.message(
      'Selelct phrase words',
      name: 'wallet_restore_enterWords',
      desc: '',
      args: [],
    );
  }

  /// `Recovery phrase`
  String get wallet_restore_recoveryPhrase {
    return Intl.message(
      'Recovery phrase',
      name: 'wallet_restore_recoveryPhrase',
      desc: '',
      args: [],
    );
  }

  /// `You didn't safed your recovery words, wanna do that now?`
  String get wallet_restore_not_safed {
    return Intl.message(
      'You didn\'t safed your recovery words, wanna do that now?',
      name: 'wallet_restore_not_safed',
      desc: '',
      args: [],
    );
  }

  /// `Enter Word`
  String get wallet_restore_word_hint {
    return Intl.message(
      'Enter Word',
      name: 'wallet_restore_word_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Word`
  String get wallet_restore_word_empty {
    return Intl.message(
      'Please enter Word',
      name: 'wallet_restore_word_empty',
      desc: '',
      args: [],
    );
  }

  /// `Word is invalid`
  String get wallet_restore_word_invalid {
    return Intl.message(
      'Word is invalid',
      name: 'wallet_restore_word_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet is empty!`
  String get wallet_empty {
    return Intl.message(
      'Your wallet is empty!',
      name: 'wallet_empty',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get wallet_receive {
    return Intl.message(
      'Receive',
      name: 'wallet_receive',
      desc: '',
      args: [],
    );
  }

  /// `Send only {coin} to this address. Sending coin or token other than {coin} to this address may result in the loss of your deposit!`
  String wallet_receive_warning(Object coin) {
    return Intl.message(
      'Send only $coin to this address. Sending coin or token other than $coin to this address may result in the loss of your deposit!',
      name: 'wallet_receive_warning',
      desc: '',
      args: [coin],
    );
  }

  /// `Wallet is synchronising right now!`
  String get wallet_locked {
    return Intl.message(
      'Wallet is synchronising right now!',
      name: 'wallet_locked',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing utxo...`
  String get wallet_operation_refresh_utxo {
    return Intl.message(
      'Refreshing utxo...',
      name: 'wallet_operation_refresh_utxo',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing utxo...done`
  String get wallet_operation_refresh_utxo_done {
    return Intl.message(
      'Refreshing utxo...done',
      name: 'wallet_operation_refresh_utxo_done',
      desc: '',
      args: [],
    );
  }

  /// `Building transaction`
  String get wallet_operation_build_tx {
    return Intl.message(
      'Building transaction',
      name: 'wallet_operation_build_tx',
      desc: '',
      args: [],
    );
  }

  /// `Create swap transaction`
  String get wallet_operation_create_swap_tx {
    return Intl.message(
      'Create swap transaction',
      name: 'wallet_operation_create_swap_tx',
      desc: '',
      args: [],
    );
  }

  /// `Sending transaction`
  String get wallet_operation_send_tx {
    return Intl.message(
      'Sending transaction',
      name: 'wallet_operation_send_tx',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing addresses ({from}/{to})`
  String wallet_operation_refresh_addresses(Object from, Object to) {
    return Intl.message(
      'Refreshing addresses ($from/$to)',
      name: 'wallet_operation_refresh_addresses',
      desc: '',
      args: [from, to],
    );
  }

  /// `Refreshing transactions ({from}/{to})`
  String wallet_operation_refresh_tx(Object from, Object to) {
    return Intl.message(
      'Refreshing transactions ($from/$to)',
      name: 'wallet_operation_refresh_tx',
      desc: '',
      args: [from, to],
    );
  }

  /// `Creating auth tx`
  String get wallet_operation_create_auth_tx {
    return Intl.message(
      'Creating auth tx',
      name: 'wallet_operation_create_auth_tx',
      desc: '',
      args: [],
    );
  }

  /// `Preparing account balance`
  String get wallet_operation_create_pepare_acc_tx {
    return Intl.message(
      'Preparing account balance',
      name: 'wallet_operation_create_pepare_acc_tx',
      desc: '',
      args: [],
    );
  }

  /// `We found some pending transactions. We try to wait for them, this could take some time!`
  String get wallet_operation_mempool_conflict_retry {
    return Intl.message(
      'We found some pending transactions. We try to wait for them, this could take some time!',
      name: 'wallet_operation_mempool_conflict_retry',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for your transaction to be reflected in the next block before proceeding with a new transaction.`
  String get wallet_operation_mempool_conflict {
    return Intl.message(
      'Please wait for your transaction to be reflected in the next block before proceeding with a new transaction.',
      name: 'wallet_operation_mempool_conflict',
      desc: '',
      args: [],
    );
  }

  /// `Wallet is not synced. Please retry your transaction.`
  String get wallet_operation_missing_inputs {
    return Intl.message(
      'Wallet is not synced. Please retry your transaction.',
      name: 'wallet_operation_missing_inputs',
      desc: '',
      args: [],
    );
  }

  /// `Addressbook`
  String get addressbook {
    return Intl.message(
      'Addressbook',
      name: 'addressbook',
      desc: '',
      args: [],
    );
  }

  /// `Add address`
  String get addressbook_add {
    return Intl.message(
      'Add address',
      name: 'addressbook_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit address`
  String get addressbook_edit {
    return Intl.message(
      'Edit address',
      name: 'addressbook_edit',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get wallet_accounts {
    return Intl.message(
      'Accounts',
      name: 'wallet_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Account index`
  String get wallet_account_index {
    return Intl.message(
      'Account index',
      name: 'wallet_account_index',
      desc: '',
      args: [],
    );
  }

  /// `Readonly`
  String get wallet_accounts_readonly {
    return Intl.message(
      'Readonly',
      name: 'wallet_accounts_readonly',
      desc: '',
      args: [],
    );
  }

  /// `Spentable`
  String get wallet_accounts_spentable {
    return Intl.message(
      'Spentable',
      name: 'wallet_accounts_spentable',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete this account?`
  String get wallet_accounts_delete {
    return Intl.message(
      'Do you want to delete this account?',
      name: 'wallet_accounts_delete',
      desc: '',
      args: [],
    );
  }

  /// `Account details`
  String get wallet_accounts_detail {
    return Intl.message(
      'Account details',
      name: 'wallet_accounts_detail',
      desc: '',
      args: [],
    );
  }

  /// `No address created yet...`
  String get wallet_accounts_empty {
    return Intl.message(
      'No address created yet...',
      name: 'wallet_accounts_empty',
      desc: '',
      args: [],
    );
  }

  /// `Create new address`
  String get wallet_accounts_address_add {
    return Intl.message(
      'Create new address',
      name: 'wallet_accounts_address_add',
      desc: '',
      args: [],
    );
  }

  /// `Select type`
  String get wallet_accounts_select_type {
    return Intl.message(
      'Select type',
      name: 'wallet_accounts_select_type',
      desc: '',
      args: [],
    );
  }

  /// `You need to create an address first!`
  String get wallet_accounts_create {
    return Intl.message(
      'You need to create an address first!',
      name: 'wallet_accounts_create',
      desc: '',
      args: [],
    );
  }

  /// `Add account`
  String get wallet_accounts_add {
    return Intl.message(
      'Add account',
      name: 'wallet_accounts_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit account`
  String get wallet_accounts_edit {
    return Intl.message(
      'Edit account',
      name: 'wallet_accounts_edit',
      desc: '',
      args: [],
    );
  }

  /// `Import account`
  String get wallet_accounts_import {
    return Intl.message(
      'Import account',
      name: 'wallet_accounts_import',
      desc: '',
      args: [],
    );
  }

  /// `Private Keys must be WIF formatted. Public Keys as P2SH addresses!`
  String get wallet_accounts_import_info {
    return Intl.message(
      'Private Keys must be WIF formatted. Public Keys as P2SH addresses!',
      name: 'wallet_accounts_import_info',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to import the Private Key for the existing account? ({pubKey})`
  String wallet_accounts_import_priv_key_for_pub_key(Object pubKey) {
    return Intl.message(
      'Do you want to import the Private Key for the existing account? ($pubKey)',
      name: 'wallet_accounts_import_priv_key_for_pub_key',
      desc: '',
      args: [pubKey],
    );
  }

  /// `The public key is invalid!`
  String get wallet_accounts_import_invalid_pub_key {
    return Intl.message(
      'The public key is invalid!',
      name: 'wallet_accounts_import_invalid_pub_key',
      desc: '',
      args: [],
    );
  }

  /// `The public key is not supported!`
  String get wallet_accounts_import_unsupported_key {
    return Intl.message(
      'The public key is not supported!',
      name: 'wallet_accounts_import_unsupported_key',
      desc: '',
      args: [],
    );
  }

  /// `The private key is invalid!`
  String get wallet_accounts_import_invalid_priv_key {
    return Intl.message(
      'The private key is invalid!',
      name: 'wallet_accounts_import_invalid_priv_key',
      desc: '',
      args: [],
    );
  }

  /// `The content is invalid!`
  String get wallet_accounts_import_invalid {
    return Intl.message(
      'The content is invalid!',
      name: 'wallet_accounts_import_invalid',
      desc: '',
      args: [],
    );
  }

  /// `The key is already imported!`
  String get wallet_accounts_key_already_imported {
    return Intl.message(
      'The key is already imported!',
      name: 'wallet_accounts_key_already_imported',
      desc: '',
      args: [],
    );
  }

  /// `The field cannot be empty!`
  String get wallet_accounts_cannot_be_empty {
    return Intl.message(
      'The field cannot be empty!',
      name: 'wallet_accounts_cannot_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Account saved`
  String get wallet_accounts_saved {
    return Intl.message(
      'Account saved',
      name: 'wallet_accounts_saved',
      desc: '',
      args: [],
    );
  }

  /// `Export private key`
  String get wallet_account_export_private_key {
    return Intl.message(
      'Export private key',
      name: 'wallet_account_export_private_key',
      desc: '',
      args: [],
    );
  }

  /// `No account selected`
  String get wallet_account_nothing_selected {
    return Intl.message(
      'No account selected',
      name: 'wallet_account_nothing_selected',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get wallet_send {
    return Intl.message(
      'Send',
      name: 'wallet_send',
      desc: '',
      args: [],
    );
  }

  /// `Change address`
  String get wallet_return_address {
    return Intl.message(
      'Change address',
      name: 'wallet_return_address',
      desc: '',
      args: [],
    );
  }

  /// `Use custom change address`
  String get wallet_use_custom_return_address {
    return Intl.message(
      'Use custom change address',
      name: 'wallet_use_custom_return_address',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get wallet_send_address {
    return Intl.message(
      'Address',
      name: 'wallet_send_address',
      desc: '',
      args: [],
    );
  }

  /// `Scan`
  String get wallet_send_address_scan {
    return Intl.message(
      'Scan',
      name: 'wallet_send_address_scan',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get wallet_send_amount {
    return Intl.message(
      'Amount',
      name: 'wallet_send_amount',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get settings_wallet {
    return Intl.message(
      'Wallet',
      name: 'settings_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Common`
  String get settings_common {
    return Intl.message(
      'Common',
      name: 'settings_common',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get settings_support {
    return Intl.message(
      'Support',
      name: 'settings_support',
      desc: '',
      args: [],
    );
  }

  /// `Telegram saiive.live`
  String get settings_support_telegram_live {
    return Intl.message(
      'Telegram saiive.live',
      name: 'settings_support_telegram_live',
      desc: '',
      args: [],
    );
  }

  /// `Telegram DeFiChain [en]`
  String get settings_support_telegram_defichain_en {
    return Intl.message(
      'Telegram DeFiChain [en]',
      name: 'settings_support_telegram_defichain_en',
      desc: '',
      args: [],
    );
  }

  /// `Telegram DeFiChain [de]`
  String get settings_support_telegram_defichain_de {
    return Intl.message(
      'Telegram DeFiChain [de]',
      name: 'settings_support_telegram_defichain_de',
      desc: '',
      args: [],
    );
  }

  /// `Wiki`
  String get settings_support_wiki {
    return Intl.message(
      'Wiki',
      name: 'settings_support_wiki',
      desc: '',
      args: [],
    );
  }

  /// `Reddit`
  String get settings_support_reddit {
    return Intl.message(
      'Reddit',
      name: 'settings_support_reddit',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get settings_support_github {
    return Intl.message(
      'GitHub',
      name: 'settings_support_github',
      desc: '',
      args: [],
    );
  }

  /// `Defichain.com`
  String get settings_support_defichain {
    return Intl.message(
      'Defichain.com',
      name: 'settings_support_defichain',
      desc: '',
      args: [],
    );
  }

  /// `Set/change password`
  String get settings_set_password {
    return Intl.message(
      'Set/change password',
      name: 'settings_set_password',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get settings_network {
    return Intl.message(
      'Network',
      name: 'settings_network',
      desc: '',
      args: [],
    );
  }

  /// `Remove Seed`
  String get settings_remove_seed {
    return Intl.message(
      'Remove Seed',
      name: 'settings_remove_seed',
      desc: '',
      args: [],
    );
  }

  /// `Show logs`
  String get settings_show_logs {
    return Intl.message(
      'Show logs',
      name: 'settings_show_logs',
      desc: '',
      args: [],
    );
  }

  /// `Logs copied...`
  String get settings_logs_copied {
    return Intl.message(
      'Logs copied...',
      name: 'settings_logs_copied',
      desc: '',
      args: [],
    );
  }

  /// `Wallet addresses`
  String get settings_show_wallet_addresses {
    return Intl.message(
      'Wallet addresses',
      name: 'settings_show_wallet_addresses',
      desc: '',
      args: [],
    );
  }

  /// `Show Seed`
  String get settings_show_seed {
    return Intl.message(
      'Show Seed',
      name: 'settings_show_seed',
      desc: '',
      args: [],
    );
  }

  /// `Removed saved seed`
  String get settings_removed_seed {
    return Intl.message(
      'Removed saved seed',
      name: 'settings_removed_seed',
      desc: '',
      args: [],
    );
  }

  /// `If you want to help making the App even better, you can donate $DFI here:`
  String get settings_donate {
    return Intl.message(
      'If you want to help making the App even better, you can donate \$DFI here:',
      name: 'settings_donate',
      desc: '',
      args: [],
    );
  }

  /// `No one who is contributing to this project is taking any responsibility of what happens to your funds.`
  String get settings_disclaimer {
    return Intl.message(
      'No one who is contributing to this project is taking any responsibility of what happens to your funds.',
      name: 'settings_disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Biometric`
  String get settings_auth_biometric {
    return Intl.message(
      'Biometric',
      name: 'settings_auth_biometric',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get settings_auth_none {
    return Intl.message(
      'None',
      name: 'settings_auth_none',
      desc: '',
      args: [],
    );
  }

  /// `Network updated...`
  String get settings_network_changed {
    return Intl.message(
      'Network updated...',
      name: 'settings_network_changed',
      desc: '',
      args: [],
    );
  }

  /// `Danger!`
  String get settings_change_network_title {
    return Intl.message(
      'Danger!',
      name: 'settings_change_network_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to switch to "Mainnet"? You alone are responsible for your funds!`
  String get settings_change_network_text {
    return Intl.message(
      'Are you sure to switch to "Mainnet"? You alone are responsible for your funds!',
      name: 'settings_change_network_text',
      desc: '',
      args: [],
    );
  }

  /// `Available balance`
  String get wallet_token_available_balance {
    return Intl.message(
      'Available balance',
      name: 'wallet_token_available_balance',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get wallet_token_transactions {
    return Intl.message(
      'Transactions',
      name: 'wallet_token_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Open in explorer`
  String get wallet_token_show_in_explorer {
    return Intl.message(
      'Open in explorer',
      name: 'wallet_token_show_in_explorer',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get receive {
    return Intl.message(
      'Receive',
      name: 'receive',
      desc: '',
      args: [],
    );
  }

  /// `Address copied to Clipboard`
  String get receive_address_copied_to_clipboard {
    return Intl.message(
      'Address copied to Clipboard',
      name: 'receive_address_copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `DEX`
  String get dex {
    return Intl.message(
      'DEX',
      name: 'dex',
      desc: '',
      args: [],
    );
  }

  /// `max`
  String get dex_add_max {
    return Intl.message(
      'max',
      name: 'dex_add_max',
      desc: '',
      args: [],
    );
  }

  /// `From Token`
  String get dex_from_token {
    return Intl.message(
      'From Token',
      name: 'dex_from_token',
      desc: '',
      args: [],
    );
  }

  /// `From Amount`
  String get dex_from_amount {
    return Intl.message(
      'From Amount',
      name: 'dex_from_amount',
      desc: '',
      args: [],
    );
  }

  /// `To Token`
  String get dex_to_token {
    return Intl.message(
      'To Token',
      name: 'dex_to_token',
      desc: '',
      args: [],
    );
  }

  /// `To Amount`
  String get dex_to_amount {
    return Intl.message(
      'To Amount',
      name: 'dex_to_amount',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get dex_price {
    return Intl.message(
      'Price',
      name: 'dex_price',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get dex_amount {
    return Intl.message(
      'Amount',
      name: 'dex_amount',
      desc: '',
      args: [],
    );
  }

  /// `Commision`
  String get dex_commission {
    return Intl.message(
      'Commision',
      name: 'dex_commission',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get dex_swap {
    return Intl.message(
      'Swap',
      name: 'dex_swap',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient Funds for Swap`
  String get dex_insufficient_funds {
    return Intl.message(
      'Insufficient Funds for Swap',
      name: 'dex_insufficient_funds',
      desc: '',
      args: [],
    );
  }

  /// `Swap successfull`
  String get dex_swap_successfull {
    return Intl.message(
      'Swap successfull',
      name: 'dex_swap_successfull',
      desc: '',
      args: [],
    );
  }

  /// `In Explorer`
  String get dex_swap_show_transaction {
    return Intl.message(
      'In Explorer',
      name: 'dex_swap_show_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Receive tokens at`
  String get dex_to_address {
    return Intl.message(
      'Receive tokens at',
      name: 'dex_to_address',
      desc: '',
      args: [],
    );
  }

  /// `DEX V2`
  String get dex_v2 {
    return Intl.message(
      'DEX V2',
      name: 'dex_v2',
      desc: '',
      args: [],
    );
  }

  /// `max`
  String get dex_v2_add_max {
    return Intl.message(
      'max',
      name: 'dex_v2_add_max',
      desc: '',
      args: [],
    );
  }

  /// `From Token`
  String get dex_v2_from_token {
    return Intl.message(
      'From Token',
      name: 'dex_v2_from_token',
      desc: '',
      args: [],
    );
  }

  /// `From Token`
  String get dex_v2_to_token {
    return Intl.message(
      'From Token',
      name: 'dex_v2_to_token',
      desc: '',
      args: [],
    );
  }

  /// `From Amount`
  String get dex_v2_from_amount {
    return Intl.message(
      'From Amount',
      name: 'dex_v2_from_amount',
      desc: '',
      args: [],
    );
  }

  /// `Max.`
  String get dex_v2_max {
    return Intl.message(
      'Max.',
      name: 'dex_v2_max',
      desc: '',
      args: [],
    );
  }

  /// `50%`
  String get dex_v2_50 {
    return Intl.message(
      '50%',
      name: 'dex_v2_50',
      desc: '',
      args: [],
    );
  }

  /// `How much from you wanna swap?`
  String get dex_v2_swap_amount {
    return Intl.message(
      'How much from you wanna swap?',
      name: 'dex_v2_swap_amount',
      desc: '',
      args: [],
    );
  }

  /// `Amount ro receive`
  String get dex_v2_amount_to_receive {
    return Intl.message(
      'Amount ro receive',
      name: 'dex_v2_amount_to_receive',
      desc: '',
      args: [],
    );
  }

  /// `price in`
  String get dex_v2_price_in {
    return Intl.message(
      'price in',
      name: 'dex_v2_price_in',
      desc: '',
      args: [],
    );
  }

  /// `Amount to be converted`
  String get dex_v2_amount_to_be_converted {
    return Intl.message(
      'Amount to be converted',
      name: 'dex_v2_amount_to_be_converted',
      desc: '',
      args: [],
    );
  }

  /// `Estimated to receive`
  String get dex_v2_estimated_to_receive {
    return Intl.message(
      'Estimated to receive',
      name: 'dex_v2_estimated_to_receive',
      desc: '',
      args: [],
    );
  }

  /// `Prices`
  String get dex_v2_prices {
    return Intl.message(
      'Prices',
      name: 'dex_v2_prices',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Details`
  String get dex_v2_tx_details {
    return Intl.message(
      'Transaction Details',
      name: 'dex_v2_tx_details',
      desc: '',
      args: [],
    );
  }

  /// `Swap Details`
  String get dex_v2_swap_details {
    return Intl.message(
      'Swap Details',
      name: 'dex_v2_swap_details',
      desc: '',
      args: [],
    );
  }

  /// `Swap was successful!`
  String get dex_v2_swap_successful {
    return Intl.message(
      'Swap was successful!',
      name: 'dex_v2_swap_successful',
      desc: '',
      args: [],
    );
  }

  /// `Good morning`
  String get home_welcome_good_morning {
    return Intl.message(
      'Good morning',
      name: 'home_welcome_good_morning',
      desc: '',
      args: [],
    );
  }

  /// `Good day`
  String get home_welcome_good_day {
    return Intl.message(
      'Good day',
      name: 'home_welcome_good_day',
      desc: '',
      args: [],
    );
  }

  /// `Good evening`
  String get home_welcome_good_evening {
    return Intl.message(
      'Good evening',
      name: 'home_welcome_good_evening',
      desc: '',
      args: [],
    );
  }

  /// `Wallet is synced...`
  String get home_welcome_account_synced {
    return Intl.message(
      'Wallet is synced...',
      name: 'home_welcome_account_synced',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizing...`
  String get home_welcome_account_syncing {
    return Intl.message(
      'Synchronizing...',
      name: 'home_welcome_account_syncing',
      desc: '',
      args: [],
    );
  }

  /// `Block Height: `
  String get home_welcome_account_block_height {
    return Intl.message(
      'Block Height: ',
      name: 'home_welcome_account_block_height',
      desc: '',
      args: [],
    );
  }

  /// `Liquidity`
  String get liquidity {
    return Intl.message(
      'Liquidity',
      name: 'liquidity',
      desc: '',
      args: [],
    );
  }

  /// `Pool-Share`
  String get liquidity_pool_share_percentage {
    return Intl.message(
      'Pool-Share',
      name: 'liquidity_pool_share_percentage',
      desc: '',
      args: [],
    );
  }

  /// `Add Liquidity`
  String get liquidity_add {
    return Intl.message(
      'Add Liquidity',
      name: 'liquidity_add',
      desc: '',
      args: [],
    );
  }

  /// `max`
  String get liquidity_add_max {
    return Intl.message(
      'max',
      name: 'liquidity_add_max',
      desc: '',
      args: [],
    );
  }

  /// `Token A`
  String get liquidity_add_token_a {
    return Intl.message(
      'Token A',
      name: 'liquidity_add_token_a',
      desc: '',
      args: [],
    );
  }

  /// `Token B`
  String get liquidity_add_token_b {
    return Intl.message(
      'Token B',
      name: 'liquidity_add_token_b',
      desc: '',
      args: [],
    );
  }

  /// `Amount A`
  String get liquidity_add_amount_a {
    return Intl.message(
      'Amount A',
      name: 'liquidity_add_amount_a',
      desc: '',
      args: [],
    );
  }

  /// `Amount B`
  String get liquidity_add_amount_b {
    return Intl.message(
      'Amount B',
      name: 'liquidity_add_amount_b',
      desc: '',
      args: [],
    );
  }

  /// `Receive shares at`
  String get liquidity_add_shares_addr {
    return Intl.message(
      'Receive shares at',
      name: 'liquidity_add_shares_addr',
      desc: '',
      args: [],
    );
  }

  /// `Pool Share`
  String get liquidity_add_pool_share {
    return Intl.message(
      'Pool Share',
      name: 'liquidity_add_pool_share',
      desc: '',
      args: [],
    );
  }

  /// `Totally pooled`
  String get liquidity_add_total_pooled {
    return Intl.message(
      'Totally pooled',
      name: 'liquidity_add_total_pooled',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient Funds for LM`
  String get liquidity_add_insufficient_funds {
    return Intl.message(
      'Insufficient Funds for LM',
      name: 'liquidity_add_insufficient_funds',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get liquidity_add_price {
    return Intl.message(
      'Price',
      name: 'liquidity_add_price',
      desc: '',
      args: [],
    );
  }

  /// `Add liquidity successfull`
  String get liqudity_add_successfull {
    return Intl.message(
      'Add liquidity successfull',
      name: 'liqudity_add_successfull',
      desc: '',
      args: [],
    );
  }

  /// `Your Liquidity`
  String get liqudity_your_liquidity {
    return Intl.message(
      'Your Liquidity',
      name: 'liqudity_your_liquidity',
      desc: '',
      args: [],
    );
  }

  /// `Pool Pairs`
  String get liqudity_pool_pairs {
    return Intl.message(
      'Pool Pairs',
      name: 'liqudity_pool_pairs',
      desc: '',
      args: [],
    );
  }

  /// `Remove Liquidity`
  String get liquidity_remove {
    return Intl.message(
      'Remove Liquidity',
      name: 'liquidity_remove',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get liquidity_remove_price {
    return Intl.message(
      'Price',
      name: 'liquidity_remove_price',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get liquidity_remove_of {
    return Intl.message(
      'of',
      name: 'liquidity_remove_of',
      desc: '',
      args: [],
    );
  }

  /// `Removed liquidity successfull`
  String get liquidity_remove_successfull {
    return Intl.message(
      'Removed liquidity successfull',
      name: 'liquidity_remove_successfull',
      desc: '',
      args: [],
    );
  }

  /// `Biometric Authentification Error`
  String get biometric_auth_error {
    return Intl.message(
      'Biometric Authentification Error',
      name: 'biometric_auth_error',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate`
  String get authenticate {
    return Intl.message(
      'Please authenticate',
      name: 'authenticate',
      desc: '',
      args: [],
    );
  }

  /// `Return to first step`
  String get pin_return {
    return Intl.message(
      'Return to first step',
      name: 'pin_return',
      desc: '',
      args: [],
    );
  }

  /// `Confirm PIN`
  String get pin_confirm {
    return Intl.message(
      'Confirm PIN',
      name: 'pin_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Enter your PIN`
  String get pin_enter {
    return Intl.message(
      'Enter your PIN',
      name: 'pin_enter',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update_title {
    return Intl.message(
      'Update',
      name: 'update_title',
      desc: '',
      args: [],
    );
  }

  /// `A new version of {appName} is available!`
  String update_text(Object appName) {
    return Intl.message(
      'A new version of $appName is available!',
      name: 'update_text',
      desc: '',
      args: [appName],
    );
  }

  /// `Install`
  String get update_start {
    return Intl.message(
      'Install',
      name: 'update_start',
      desc: '',
      args: [],
    );
  }

  /// `Abort`
  String get update_cancel {
    return Intl.message(
      'Abort',
      name: 'update_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Expert mode`
  String get expert_title {
    return Intl.message(
      'Expert mode',
      name: 'expert_title',
      desc: '',
      args: [],
    );
  }

  /// `Expert`
  String get expert {
    return Intl.message(
      'Expert',
      name: 'expert',
      desc: '',
      args: [],
    );
  }

  /// `Buy/Sell DFI`
  String get dfx_buy_title {
    return Intl.message(
      'Buy/Sell DFI',
      name: 'dfx_buy_title',
      desc: '',
      args: [],
    );
  }

  /// `Buy address`
  String get dfx_buy_address {
    return Intl.message(
      'Buy address',
      name: 'dfx_buy_address',
      desc: '',
      args: [],
    );
  }

  /// `Loans are currently a Beta Feature! Use at your own risk`
  String get loan_beta {
    return Intl.message(
      'Loans are currently a Beta Feature! Use at your own risk',
      name: 'loan_beta',
      desc: '',
      args: [],
    );
  }

  /// `Vaults`
  String get loan_vaults {
    return Intl.message(
      'Vaults',
      name: 'loan_vaults',
      desc: '',
      args: [],
    );
  }

  /// `Vault`
  String get loan_vault {
    return Intl.message(
      'Vault',
      name: 'loan_vault',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get loan_amount {
    return Intl.message(
      'Amount',
      name: 'loan_amount',
      desc: '',
      args: [],
    );
  }

  /// `Current Amount`
  String get loan_current_amount {
    return Intl.message(
      'Current Amount',
      name: 'loan_current_amount',
      desc: '',
      args: [],
    );
  }

  /// `Current Value (USD)`
  String get loan_current_amount_usd {
    return Intl.message(
      'Current Value (USD)',
      name: 'loan_current_amount_usd',
      desc: '',
      args: [],
    );
  }

  /// `Browse Loans`
  String get loan_browse_loans {
    return Intl.message(
      'Browse Loans',
      name: 'loan_browse_loans',
      desc: '',
      args: [],
    );
  }

  /// `Your Loans`
  String get loan_your_loans {
    return Intl.message(
      'Your Loans',
      name: 'loan_your_loans',
      desc: '',
      args: [],
    );
  }

  /// `No Vault created`
  String get loan_no_vault_created {
    return Intl.message(
      'No Vault created',
      name: 'loan_no_vault_created',
      desc: '',
      args: [],
    );
  }

  /// `To get started, create a vault add DFI and other tokens as collateral`
  String get loan_vault_creation_info {
    return Intl.message(
      'To get started, create a vault add DFI and other tokens as collateral',
      name: 'loan_vault_creation_info',
      desc: '',
      args: [],
    );
  }

  /// `Create Vault`
  String get loan_create_vault {
    return Intl.message(
      'Create Vault',
      name: 'loan_create_vault',
      desc: '',
      args: [],
    );
  }

  /// `Interest`
  String get loan_interest {
    return Intl.message(
      'Interest',
      name: 'loan_interest',
      desc: '',
      args: [],
    );
  }

  /// `Price (USD)`
  String get loan_price_usd {
    return Intl.message(
      'Price (USD)',
      name: 'loan_price_usd',
      desc: '',
      args: [],
    );
  }

  /// `Collaterals`
  String get loan_collaterals {
    return Intl.message(
      'Collaterals',
      name: 'loan_collaterals',
      desc: '',
      args: [],
    );
  }

  /// `Active Loans`
  String get loan_active_loans {
    return Intl.message(
      'Active Loans',
      name: 'loan_active_loans',
      desc: '',
      args: [],
    );
  }

  /// `Total Loan Amount`
  String get loan_total_loan_amount {
    return Intl.message(
      'Total Loan Amount',
      name: 'loan_total_loan_amount',
      desc: '',
      args: [],
    );
  }

  /// `Collateral Amount`
  String get loan_collateral_amount {
    return Intl.message(
      'Collateral Amount',
      name: 'loan_collateral_amount',
      desc: '',
      args: [],
    );
  }

  /// `Collateral Ratio`
  String get loan_collateral_ratio {
    return Intl.message(
      'Collateral Ratio',
      name: 'loan_collateral_ratio',
      desc: '',
      args: [],
    );
  }

  /// `No active Loans`
  String get loan_no_active_loans {
    return Intl.message(
      'No active Loans',
      name: 'loan_no_active_loans',
      desc: '',
      args: [],
    );
  }

  /// `Vault was successfully closed`
  String get loan_close_vault_success {
    return Intl.message(
      'Vault was successfully closed',
      name: 'loan_close_vault_success',
      desc: '',
      args: [],
    );
  }

  /// `Vault was successfully created`
  String get loan_create_vault_success {
    return Intl.message(
      'Vault was successfully created',
      name: 'loan_create_vault_success',
      desc: '',
      args: [],
    );
  }

  /// `Borrow was successfully.`
  String get loan_borrow_success {
    return Intl.message(
      'Borrow was successfully.',
      name: 'loan_borrow_success',
      desc: '',
      args: [],
    );
  }

  /// `Collateral was successfully added`
  String get loan_collateral_success {
    return Intl.message(
      'Collateral was successfully added',
      name: 'loan_collateral_success',
      desc: '',
      args: [],
    );
  }

  /// `Loan was paid back successfully`
  String get loan_payback_success {
    return Intl.message(
      'Loan was paid back successfully',
      name: 'loan_payback_success',
      desc: '',
      args: [],
    );
  }

  /// `Borrowed Tokens`
  String get loan_borrowed_tokens {
    return Intl.message(
      'Borrowed Tokens',
      name: 'loan_borrowed_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Interest amount`
  String get loan_interest_amount {
    return Intl.message(
      'Interest amount',
      name: 'loan_interest_amount',
      desc: '',
      args: [],
    );
  }

  /// `Amount Payable`
  String get loan_amount_payable {
    return Intl.message(
      'Amount Payable',
      name: 'loan_amount_payable',
      desc: '',
      args: [],
    );
  }

  /// `Price per Token`
  String get loan_price_per_token {
    return Intl.message(
      'Price per Token',
      name: 'loan_price_per_token',
      desc: '',
      args: [],
    );
  }

  /// `Payback Loan`
  String get loan_payback_loan {
    return Intl.message(
      'Payback Loan',
      name: 'loan_payback_loan',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient tokens to paybkack loan!`
  String get loan_payback_loan_insufficient_funds {
    return Intl.message(
      'Insufficient tokens to paybkack loan!',
      name: 'loan_payback_loan_insufficient_funds',
      desc: '',
      args: [],
    );
  }

  /// `Borrow more`
  String get loan_borrow_more {
    return Intl.message(
      'Borrow more',
      name: 'loan_borrow_more',
      desc: '',
      args: [],
    );
  }

  /// `Create Loan`
  String get loan_borrow {
    return Intl.message(
      'Create Loan',
      name: 'loan_borrow',
      desc: '',
      args: [],
    );
  }

  /// `Min. collateral ratio`
  String get loan_min_collateral_ratio {
    return Intl.message(
      'Min. collateral ratio',
      name: 'loan_min_collateral_ratio',
      desc: '',
      args: [],
    );
  }

  /// `Vault Interest`
  String get loan_vault_interest {
    return Intl.message(
      'Vault Interest',
      name: 'loan_vault_interest',
      desc: '',
      args: [],
    );
  }

  /// `Collateral Value`
  String get loan_collateral_value {
    return Intl.message(
      'Collateral Value',
      name: 'loan_collateral_value',
      desc: '',
      args: [],
    );
  }

  /// `Vault Health`
  String get loan_vault_health {
    return Intl.message(
      'Vault Health',
      name: 'loan_vault_health',
      desc: '',
      args: [],
    );
  }

  /// `Loan Scheme`
  String get loan_vault_loan_scheme {
    return Intl.message(
      'Loan Scheme',
      name: 'loan_vault_loan_scheme',
      desc: '',
      args: [],
    );
  }

  /// `Vault Details`
  String get loan_vault_details {
    return Intl.message(
      'Vault Details',
      name: 'loan_vault_details',
      desc: '',
      args: [],
    );
  }

  /// `No Collateral`
  String get loan_no_collateral_amounts {
    return Intl.message(
      'No Collateral',
      name: 'loan_no_collateral_amounts',
      desc: '',
      args: [],
    );
  }

  /// `The activity of this vault has been temporarily halted due to price volatility in the market. This vault will resume its activity once the market stabilizes.`
  String get loan_vault_halted_info {
    return Intl.message(
      'The activity of this vault has been temporarily halted due to price volatility in the market. This vault will resume its activity once the market stabilizes.',
      name: 'loan_vault_halted_info',
      desc: '',
      args: [],
    );
  }

  /// `Your collateral has to be at lea,st 50% DFI in order to get a loan.`
  String get loan_collateral_dfi_ratio {
    return Intl.message(
      'Your collateral has to be at lea,st 50% DFI in order to get a loan.',
      name: 'loan_collateral_dfi_ratio',
      desc: '',
      args: [],
    );
  }

  /// `Your collateral ratio fell bellow the defined ratio in the Scheme.`
  String get loan_collateral_ratio_to_little {
    return Intl.message(
      'Your collateral ratio fell bellow the defined ratio in the Scheme.',
      name: 'loan_collateral_ratio_to_little',
      desc: '',
      args: [],
    );
  }

  /// `Change Collateral`
  String get loan_change_collateral {
    return Intl.message(
      'Change Collateral',
      name: 'loan_change_collateral',
      desc: '',
      args: [],
    );
  }

  /// `Close Vault`
  String get loan_close_vault {
    return Intl.message(
      'Close Vault',
      name: 'loan_close_vault',
      desc: '',
      args: [],
    );
  }

  /// `Close vault not possible, you still have open loans in it!`
  String get loan_close_vault_not_possible_due_loans {
    return Intl.message(
      'Close vault not possible, you still have open loans in it!',
      name: 'loan_close_vault_not_possible_due_loans',
      desc: '',
      args: [],
    );
  }

  /// `Active Loans`
  String get loan_vault_details_tab_active_loan {
    return Intl.message(
      'Active Loans',
      name: 'loan_vault_details_tab_active_loan',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get loan_vault_details_tab_details {
    return Intl.message(
      'Details',
      name: 'loan_vault_details_tab_details',
      desc: '',
      args: [],
    );
  }

  /// `Collaterals`
  String get loan_vault_details_tab_collaterals {
    return Intl.message(
      'Collaterals',
      name: 'loan_vault_details_tab_collaterals',
      desc: '',
      args: [],
    );
  }

  /// `Auctions`
  String get loan_vault_details_tab_auctions {
    return Intl.message(
      'Auctions',
      name: 'loan_vault_details_tab_auctions',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Type`
  String get loan_transaction_type {
    return Intl.message(
      'Transaction Type',
      name: 'loan_transaction_type',
      desc: '',
      args: [],
    );
  }

  /// `Vault fee`
  String get loan_create_vault_fee {
    return Intl.message(
      'Vault fee',
      name: 'loan_create_vault_fee',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Fee`
  String get loan_create_est_fee {
    return Intl.message(
      'Estimated Fee',
      name: 'loan_create_est_fee',
      desc: '',
      args: [],
    );
  }

  /// `Total transaction cost`
  String get loan_create_fees {
    return Intl.message(
      'Total transaction cost',
      name: 'loan_create_fees',
      desc: '',
      args: [],
    );
  }

  /// `Interest Rate (APR)`
  String get loan_vault_interest_rate_apr {
    return Intl.message(
      'Interest Rate (APR)',
      name: 'loan_vault_interest_rate_apr',
      desc: '',
      args: [],
    );
  }

  /// `You are creating a vault`
  String get loan_create_vault_info {
    return Intl.message(
      'You are creating a vault',
      name: 'loan_create_vault_info',
      desc: '',
      args: [],
    );
  }

  /// `ID will be generated once the vault has been created`
  String get loan_create_id_generated {
    return Intl.message(
      'ID will be generated once the vault has been created',
      name: 'loan_create_id_generated',
      desc: '',
      args: [],
    );
  }

  /// `Use custom vault owner address`
  String get loan_vault_customer_owner_address {
    return Intl.message(
      'Use custom vault owner address',
      name: 'loan_vault_customer_owner_address',
      desc: '',
      args: [],
    );
  }

  /// `Vault owner address`
  String get loan_vault_owner_address {
    return Intl.message(
      'Vault owner address',
      name: 'loan_vault_owner_address',
      desc: '',
      args: [],
    );
  }

  /// `Change address`
  String get loan_return_address {
    return Intl.message(
      'Change address',
      name: 'loan_return_address',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get loan_continue {
    return Intl.message(
      'Continue',
      name: 'loan_continue',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get loan_cancel {
    return Intl.message(
      'Cancel',
      name: 'loan_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Create Vault`
  String get loan_confirm_create_vault {
    return Intl.message(
      'Confirm Create Vault',
      name: 'loan_confirm_create_vault',
      desc: '',
      args: [],
    );
  }

  /// `Choose loan scheme for your vault`
  String get loan_create_choose_scheme {
    return Intl.message(
      'Choose loan scheme for your vault',
      name: 'loan_create_choose_scheme',
      desc: '',
      args: [],
    );
  }

  /// `This sets the minimum collateral ratio and the vault's interest rate.`
  String get loan_create_choose_schema_info {
    return Intl.message(
      'This sets the minimum collateral ratio and the vault\'s interest rate.',
      name: 'loan_create_choose_schema_info',
      desc: '',
      args: [],
    );
  }

  /// `You are borrowing`
  String get loan_you_are_borrowing {
    return Intl.message(
      'You are borrowing',
      name: 'loan_you_are_borrowing',
      desc: '',
      args: [],
    );
  }

  /// `Loan Tokens to borrow`
  String get loan_tokens_to_borrow {
    return Intl.message(
      'Loan Tokens to borrow',
      name: 'loan_tokens_to_borrow',
      desc: '',
      args: [],
    );
  }

  /// `Token Interest`
  String get loan_token_interest {
    return Intl.message(
      'Token Interest',
      name: 'loan_token_interest',
      desc: '',
      args: [],
    );
  }

  /// `Total Interest Amount`
  String get loan_token_interest_amount {
    return Intl.message(
      'Total Interest Amount',
      name: 'loan_token_interest_amount',
      desc: '',
      args: [],
    );
  }

  /// `Total Loan + interest`
  String get loan_token_total_interest {
    return Intl.message(
      'Total Loan + interest',
      name: 'loan_token_total_interest',
      desc: '',
      args: [],
    );
  }

  /// `Interest (Vault + Token)`
  String get loan_token_total_interest_rate {
    return Intl.message(
      'Interest (Vault + Token)',
      name: 'loan_token_total_interest_rate',
      desc: '',
      args: [],
    );
  }

  /// `Total Loan USD`
  String get loan_total_loan_usd {
    return Intl.message(
      'Total Loan USD',
      name: 'loan_total_loan_usd',
      desc: '',
      args: [],
    );
  }

  /// `Vault ID`
  String get loan_vault_id {
    return Intl.message(
      'Vault ID',
      name: 'loan_vault_id',
      desc: '',
      args: [],
    );
  }

  /// `Resulting collateral Ratio`
  String get loan_resulting_collateral {
    return Intl.message(
      'Resulting collateral Ratio',
      name: 'loan_resulting_collateral',
      desc: '',
      args: [],
    );
  }

  /// `Borrow Loan Token Confirm`
  String get loan_borrow_confirm_title {
    return Intl.message(
      'Borrow Loan Token Confirm',
      name: 'loan_borrow_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Borrow Loan Token`
  String get loan_borrow_title {
    return Intl.message(
      'Borrow Loan Token',
      name: 'loan_borrow_title',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Details`
  String get loan_transaction_details {
    return Intl.message(
      'Transaction Details',
      name: 'loan_transaction_details',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Results`
  String get loan_transaction_result {
    return Intl.message(
      'Transaction Results',
      name: 'loan_transaction_result',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Borrow`
  String get loan_borrow_confirm {
    return Intl.message(
      'Confirm Borrow',
      name: 'loan_borrow_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Choose a Loan Token`
  String get loan_borrow_choose_token {
    return Intl.message(
      'Choose a Loan Token',
      name: 'loan_borrow_choose_token',
      desc: '',
      args: [],
    );
  }

  /// `Choose your Vault`
  String get loan_borrow_choose_vault {
    return Intl.message(
      'Choose your Vault',
      name: 'loan_borrow_choose_vault',
      desc: '',
      args: [],
    );
  }

  /// `Total Collateral`
  String get loan_total_collateral {
    return Intl.message(
      'Total Collateral',
      name: 'loan_total_collateral',
      desc: '',
      args: [],
    );
  }

  /// `Loan Token`
  String get loan_token {
    return Intl.message(
      'Loan Token',
      name: 'loan_token',
      desc: '',
      args: [],
    );
  }

  /// `How much to add?`
  String get loan_borrow_amount {
    return Intl.message(
      'How much to add?',
      name: 'loan_borrow_amount',
      desc: '',
      args: [],
    );
  }

  /// `Add Collateral Confirm`
  String get loan_add_collateral_confirm_title {
    return Intl.message(
      'Add Collateral Confirm',
      name: 'loan_add_collateral_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Collaterals`
  String get loan_current_collateral {
    return Intl.message(
      'Current Collaterals',
      name: 'loan_current_collateral',
      desc: '',
      args: [],
    );
  }

  /// `Changes`
  String get loan_collateral_changes {
    return Intl.message(
      'Changes',
      name: 'loan_collateral_changes',
      desc: '',
      args: [],
    );
  }

  /// `Final Collateral after TX`
  String get loan_collateral_after_tx {
    return Intl.message(
      'Final Collateral after TX',
      name: 'loan_collateral_after_tx',
      desc: '',
      args: [],
    );
  }

  /// `No Collaterals`
  String get loan_no_collaterals {
    return Intl.message(
      'No Collaterals',
      name: 'loan_no_collaterals',
      desc: '',
      args: [],
    );
  }

  /// `Add Collateral`
  String get loan_add_collateral_title {
    return Intl.message(
      'Add Collateral',
      name: 'loan_add_collateral_title',
      desc: '',
      args: [],
    );
  }

  /// `Add token as collateral`
  String get loan_add_token_as_collateral {
    return Intl.message(
      'Add token as collateral',
      name: 'loan_add_token_as_collateral',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get loan_add_collateral_available {
    return Intl.message(
      'Available',
      name: 'loan_add_collateral_available',
      desc: '',
      args: [],
    );
  }

  /// `How much to add?`
  String get loan_add_collateral_how_much {
    return Intl.message(
      'How much to add?',
      name: 'loan_add_collateral_how_much',
      desc: '',
      args: [],
    );
  }

  /// `How much to change?`
  String get loan_change_collateral_how_much {
    return Intl.message(
      'How much to change?',
      name: 'loan_change_collateral_how_much',
      desc: '',
      args: [],
    );
  }

  /// `Amount is invalid, insufficient funds`
  String get loan_add_collateral_insufficient_funds {
    return Intl.message(
      'Amount is invalid, insufficient funds',
      name: 'loan_add_collateral_insufficient_funds',
      desc: '',
      args: [],
    );
  }

  /// `Payback`
  String get loan_payback {
    return Intl.message(
      'Payback',
      name: 'loan_payback',
      desc: '',
      args: [],
    );
  }

  /// `Payback Loan`
  String get loan_payback_title {
    return Intl.message(
      'Payback Loan',
      name: 'loan_payback_title',
      desc: '',
      args: [],
    );
  }

  /// `Available Balance`
  String get loan_payback_available_balance {
    return Intl.message(
      'Available Balance',
      name: 'loan_payback_available_balance',
      desc: '',
      args: [],
    );
  }

  /// `Tokens to pay back`
  String get loan_tokens_to_pay_back {
    return Intl.message(
      'Tokens to pay back',
      name: 'loan_tokens_to_pay_back',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get loan_payback_value {
    return Intl.message(
      'Value',
      name: 'loan_payback_value',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get loan_collateral_edit {
    return Intl.message(
      'Edit',
      name: 'loan_collateral_edit',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}