import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final List<Locale> _availableLocales = [Locale('en'), Locale('pt')];

  Locale get locale => _locale;
  List<Locale> get availableLocales => _availableLocales;

  void updateLanguage(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
