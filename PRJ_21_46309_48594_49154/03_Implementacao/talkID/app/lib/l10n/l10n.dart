import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en', 'GB'),
    const Locale('pt'),
  ];

  static String getFlag(String countryCode){
    switch(countryCode) {
      case 'pt':
        return '🇵🇹';
      default:
        return '🇬🇧';
    }
  }

  static String getCountryName(String countryCode){
    switch (countryCode){
      case 'pt':
        return 'Portugal';
      default:
        return 'English';
    }
  }
}