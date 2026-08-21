import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  bool get isRussian => _locale.languageCode == 'ru';

  bool get isKazakh => _locale.languageCode == 'kk';

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

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'ru' && languageCode != 'kk') {
      return;
    }

    if (_locale.languageCode == languageCode) {
      return;
    }

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);

    notifyListeners();
  }

  Future<void> setRussian() async {
    await setLocale('ru');
  }

  Future<void> setKazakh() async {
    await setLocale('kk');
  }
}
