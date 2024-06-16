import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:language_code/language_code.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const systemLangCode = 'system';

  static const _fallbackLanguage = 'en';
  static const _fallbackCountry = 'US';
  static const _fallbackName = 'United States Dollar';
  static const _fallbackCurrency = '\$';
  static const _fallbackLocale = Locale(_fallbackLanguage, _fallbackCountry);

  Locale _locale = _fallbackLocale;
  String _languageSetting = systemLangCode;
  String _currencyName = _fallbackName;
  String _currencySymbol = _fallbackCurrency;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    var locale = _fallbackLocale;
    var langCode = systemLangCode;

    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');

    try {
      if (savedLocale == null || savedLocale == systemLangCode) {
        locale = LanguageCode.locale;
        langCode = systemLangCode;
      } else {
        locale = Locale(savedLocale);
        langCode = locale.languageCode;
      }

      final format = NumberFormat.simpleCurrency(locale: locale.toString());

      _locale = locale;
      _languageSetting = langCode;
      _currencyName = format.currencyName ?? _fallbackName;
      _currencySymbol = format.currencySymbol;
    } catch (e) {
      logger.e('Error when fetching user language: $e');
    }

    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    await _loadLocale();

    notifyListeners();
  }

  String get languageSetting => _languageSetting;
  Locale? get locale => _locale;
  String get languageCode => _locale.languageCode;
  String get countryCode => _locale.countryCode ?? _fallbackCountry;
  String get currencyName => _currencyName;
  String get currencySymbol => _currencySymbol;
}
