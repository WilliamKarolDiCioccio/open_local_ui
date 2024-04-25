import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;

    notifyListeners();
  }

  String get languageCode => _locale?.languageCode ?? 'en';
}
