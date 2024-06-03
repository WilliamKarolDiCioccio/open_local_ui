import 'package:flutter/material.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:intl/intl.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  String? _languageCode;
  // ignore: unused_field
  String? _countryCode;
  String? _currencyName;
  String? _currencySymbol;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');

    if (savedLocale == null) {
      final deviceLocale = await Devicelocale.currentLocale;

      if (deviceLocale != null && deviceLocale.length >= 2) {
        try {
          _languageCode = deviceLocale.substring(0, 2);
        } catch (e) {
          logger.e('Error when fetching user language: $e');
        }
      }

      if (deviceLocale != null && deviceLocale.length >= 5) {
        try {
          _countryCode = deviceLocale.substring(3, 5);
        } catch (e) {
          logger.e('Error when fetching user country: $e');
        }
      }

      final format = NumberFormat.simpleCurrency(
        locale: deviceLocale ?? 'en_US',
      );

      _currencyName = format.currencyName;
      _currencySymbol = format.currencySymbol;

      _locale = Locale(_languageCode ?? 'en');
    } else {
      _locale = Locale(savedLocale);
    }

    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = Locale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);

    _languageCode = locale.substring(0, 2);

    notifyListeners();
  }

  Locale? get locale => _locale;

  String get languageCode => _locale?.languageCode ?? 'en';
  String get countryCode => _locale?.countryCode ?? 'US';
  String get currencyName => _currencyName ?? 'United States Dollar';
  String get currencySymbol => _currencySymbol ?? '\$';
}
