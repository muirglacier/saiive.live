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

  /// `DeFiChain Wallet`
  String get title {
    return Intl.message(
      'DeFiChain Wallet',
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
  String get home_liquitiy {
    return Intl.message(
      'Liquidity',
      name: 'home_liquitiy',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
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