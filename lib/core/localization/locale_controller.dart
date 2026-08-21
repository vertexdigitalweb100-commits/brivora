import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);

    if (languageCode == 'kk') {
      _locale = const Locale('kk');
    } else {
      _locale = const Locale('ru');
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'ru' && locale.languageCode != 'kk') {
      return;
    }

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setRussian() async {
    await setLocale(const Locale('ru'));
  }

  Future<void> setKazakh() async {
    await setLocale(const Locale('kk'));
  }
}
