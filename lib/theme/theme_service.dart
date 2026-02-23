import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeService extends ChangeNotifier {
  static const _themeKey = 'selected_theme';
  AppThemeMode _mode = AppThemeMode.playful;

  AppThemeMode get mode => _mode;
  AppTheme get theme => switch (_mode) {
    AppThemeMode.playful => AppTheme.playful,
    AppThemeMode.minimalistic => AppTheme.minimalistic,
    AppThemeMode.modern => AppTheme.modern,
    AppThemeMode.dark => AppTheme.dark,
  };

  bool get isPlayful => _mode == AppThemeMode.playful;
  bool get isMinimalistic => _mode == AppThemeMode.minimalistic;
  bool get isModern => _mode == AppThemeMode.modern;
  bool get isDark => _mode == AppThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _mode = switch (savedTheme) {
        'playful' => AppThemeMode.playful,
        'minimalistic' => AppThemeMode.minimalistic,
        'modern' => AppThemeMode.modern,
        'dark' => AppThemeMode.dark,
        _ => AppThemeMode.playful,
      };
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    final themeName = switch (mode) {
      AppThemeMode.playful => 'playful',
      AppThemeMode.minimalistic => 'minimalistic',
      AppThemeMode.modern => 'modern',
      AppThemeMode.dark => 'dark',
    };
    await prefs.setString(_themeKey, themeName);
    notifyListeners();
  }
}
