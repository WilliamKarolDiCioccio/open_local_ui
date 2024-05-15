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

  void setLocale(String locale) async {
    _locale = Locale(locale);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('locale', locale);

    notifyListeners();
  }

  Locale? get locale => _locale;

  String get languageCode => _locale?.languageCode ?? 'en';
}
