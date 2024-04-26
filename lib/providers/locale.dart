import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  LocaleProvider() {
    loadLocale();
  }

  void loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString('locale') ?? 'en');
  }

  void setLocale(Locale locale) {
    _locale = locale;

    notifyListeners();
  }

  Locale? get locale => _locale;

  String get languageCode => _locale?.languageCode ?? 'en';
}
