import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeService extends ChangeNotifier {
  static const _themeKey = 'selected_theme';
  AppThemeMode _mode = AppThemeMode.playful;

  AppThemeMode get mode => _mode;
  AppTheme get theme =>
      _mode == AppThemeMode.playful ? AppTheme.playful : AppTheme.modest;

  bool get isPlayful => _mode == AppThemeMode.playful;
  bool get isModest => _mode == AppThemeMode.modest;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _mode = savedTheme == 'playful'
          ? AppThemeMode.playful
          : AppThemeMode.modest;
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == AppThemeMode.playful ? 'playful' : 'modest',
    );
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _mode == AppThemeMode.playful
        ? AppThemeMode.modest
        : AppThemeMode.playful;
    await setMode(newMode);
  }
}
