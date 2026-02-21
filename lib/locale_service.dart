import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const _localeKey = 'selected_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isChinese => _locale.languageCode == 'zh';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);
    if (savedCode != null) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('zh')
        : const Locale('en');
    await setLocale(newLocale);
  }
}
