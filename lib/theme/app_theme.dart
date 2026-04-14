import 'package:flutter/material.dart';

enum AppThemeMode { playful, minimalistic, modern, dark }

class AppTheme {
  final String name;
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color cardShadowColor;
  final Color groupHeaderColor;
  final Color groupHeaderHoverColor;
  final Color groupHeaderBorderColor;
  final Color dropZoneHoverColor;
  final Color dropZoneTextColor;
  final Color floatingActionButtonColor;
  final Color appBarGradientStart;
  final Color appBarGradientEnd;
  final Color folderIconColor;
  final Color playButtonColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color selectedGamesListItemColor;
  final Color correctColor;
  final Color wrongColor;

  const AppTheme({
    required this.name,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.cardShadowColor,
    required this.groupHeaderColor,
    required this.groupHeaderHoverColor,
    required this.groupHeaderBorderColor,
    required this.dropZoneHoverColor,
    required this.dropZoneTextColor,
    required this.floatingActionButtonColor,
    required this.appBarGradientStart,
    required this.appBarGradientEnd,
    required this.folderIconColor,
    required this.playButtonColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.selectedGamesListItemColor,
    required this.correctColor,
    required this.wrongColor,
  });

  bool get isPlayful => name == 'playful';
  bool get isMinimalistic => name == 'minimalistic';
  bool get isModern => name == 'modern';
  bool get isDark => name == 'dark';

  static const playfulSecondaryColor = Color.fromARGB(255, 197, 247, 255);

  static const AppTheme playful = AppTheme(
    name: 'playful',
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFE1C5E5), Color(0xFF80DEEA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFFF8BBD0), Color(0xFF4DD0E1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: playfulSecondaryColor,
    accentColor: Color(0xFFFF4081),
    buttonColor: playfulSecondaryColor,
    buttonTextColor: Color(0xDD000000),
    cardShadowColor: Color(0x26000000),
    groupHeaderColor: Color(0x99FFFFFF),
    groupHeaderHoverColor: Color(0x1A9C27B0),
    groupHeaderBorderColor: Color(0xFFAB47BC),
    dropZoneHoverColor: Color(0x1AFF9800),
    dropZoneTextColor: Color(0xFFF57C00),
    floatingActionButtonColor: playfulSecondaryColor,
    appBarGradientStart: Color(0xFFF8BBD0),
    appBarGradientEnd: Color(0xFF4DD0E1),
    folderIconColor: Color(0xFFAB47BC),
    playButtonColor: playfulSecondaryColor,
    primaryTextColor: Color(0xDD000000),
    secondaryTextColor: Color(0x8A000000),
    selectedGamesListItemColor: Color(0xFFFAFAFA),
    correctColor: Color(0xFF4CAF50),
    wrongColor: Color(0xFFE57373),
  );

  static const AppTheme minimalistic = AppTheme(
    name: 'minimalistic',
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryColor: Color(0xFF2C2C2C),
    secondaryColor: Color(0xFF505050),
    accentColor: Color(0xFF007AFF),
    buttonColor: Color(0xFF007AFF),
    buttonTextColor: Color(0xFFFFFFFF),
    cardShadowColor: Color(0x1A000000),
    groupHeaderColor: Color(0xFFFFFFFF),
    groupHeaderHoverColor: Color(0xFFF0F0F0),
    groupHeaderBorderColor: Color(0xFFD0D0D0),
    dropZoneHoverColor: Color(0xFFE8E8E8),
    dropZoneTextColor: Color(0xFF505050),
    floatingActionButtonColor: Color(0xFF007AFF),
    appBarGradientStart: Color(0xFFFFFFFF),
    appBarGradientEnd: Color(0xFFF5F5F5),
    folderIconColor: Color(0xFF505050),
    playButtonColor: Color(0xFF007AFF),
    primaryTextColor: Color(0xFF2C2C2C),
    secondaryTextColor: Color(0xFF505050),
    selectedGamesListItemColor: Color(0xFFFAFAFA),
    correctColor: Color(0xFF4CAF50),
    wrongColor: Color(0xFFEF5350),
  );

  static const AppTheme modern = AppTheme(
    name: 'modern',
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFFAF5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryColor: Color(0xFF7C3AED),
    secondaryColor: Color(0xFF8B5CF6),
    accentColor: Color(0xFFEC4899),
    buttonColor: Color(0xFF7C3AED),
    buttonTextColor: Color(0xFFFFFFFF),
    cardShadowColor: Color(0x1D7C3AED),
    groupHeaderColor: Color(0xE6FFFFFF),
    groupHeaderHoverColor: Color(0x1A7C3AED),
    groupHeaderBorderColor: Color(0xFFC4B5FD),
    dropZoneHoverColor: Color(0x1AEC4899),
    dropZoneTextColor: Color(0xFFBE185D),
    floatingActionButtonColor: Color(0xFF8B5CF6),
    appBarGradientStart: Color(0xFFFFFFFF),
    appBarGradientEnd: Color(0xFFFAF5FF),
    folderIconColor: Color(0xFF7C3AED),
    playButtonColor: Color(0xFF8B5CF6),
    primaryTextColor: Color(0xFF1E1B4B),
    secondaryTextColor: Color(0xFF6B7280),
    selectedGamesListItemColor: Color(0xFFFAFAFA),
    correctColor: Color(0xFF10B981),
    wrongColor: Color(0xFFF472B6),
  );

  static const AppTheme dark = AppTheme(
    name: 'dark',
    backgroundGradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 32, 32, 32),
        Color.fromARGB(255, 32, 32, 32),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF2D2D3A), Color(0xFF3D3D4A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryColor: Color(0xFF7C3AED),
    secondaryColor: Color(0xFF6366F1),
    accentColor: Color(0xFFEC4899),
    buttonColor: Color(0xFF7C3AED),
    buttonTextColor: Color(0xFFFFFFFF),
    cardShadowColor: Color(0x40000000),
    groupHeaderColor: Color(0xFF2D2D3A),
    groupHeaderHoverColor: Color(0xFF3D3D4A),
    groupHeaderBorderColor: Color(0xFF4B4B5C),
    dropZoneHoverColor: Color(0x20EC4899),
    dropZoneTextColor: Color(0xFFEC4899),
    floatingActionButtonColor: Color(0xFF7C3AED),
    appBarGradientStart: Color(0xFF1A1A2E),
    appBarGradientEnd: Color(0xFF0F0F23),
    folderIconColor: Color(0xFF7C3AED),
    playButtonColor: Color(0xFF7C3AED),
    primaryTextColor: Color(0xFFE5E5E5),
    secondaryTextColor: Color(0xFF9CA3AF),
    selectedGamesListItemColor: Color(0xFF3D3D4A),
    correctColor: Color(0xFF22C55E),
    wrongColor: Color(0xFFEF4444),
  );

  LinearGradient gradientFromColors(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color cardColorAtIndex(int index) {
    if (this == AppTheme.playful) {
      return Colors.primaries[index % Colors.primaries.length].shade100;
    }
    if (this == AppTheme.dark) {
      return const Color(0xFF3D3D4A);
    }
    return const Color(0xFFFFFFFF);
  }

  LinearGradient cardGradientAtIndex(int index) {
    if (this == AppTheme.minimalistic) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (this == AppTheme.modern) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFAF5FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (this == AppTheme.dark) {
      return const LinearGradient(
        colors: [Color(0xFF3D3D4A), Color(0xFF2D2D3A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final primary1 = Colors.primaries[index % Colors.primaries.length];
    final primary2 = Colors.primaries[(index + 3) % Colors.primaries.length];
    return LinearGradient(
      colors: [primary1.shade100, primary2.shade200],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient randomGradient(int hash) {
    if (this == AppTheme.minimalistic) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (this == AppTheme.modern) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (this == AppTheme.dark) {
      return const LinearGradient(
        colors: [Color(0xFF4B4B5C), Color(0xFF3D3D4A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final primary1 = Colors.primaries[hash % Colors.primaries.length];
    final primary2 = Colors.primaries[(hash + 3) % Colors.primaries.length];
    return LinearGradient(
      colors: [primary1.shade200, primary2.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  ThemeData toMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
