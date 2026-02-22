import 'package:flutter/material.dart';

enum AppThemeMode { playful, modest }

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
  });

  bool get isPlayful => name == 'playful';
  bool get isModest => name == 'modest';

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
    secondaryColor: Color(0xFF00BCD4),
    accentColor: Color(0xFFFF4081),
    buttonColor: Color(0xFF4DD0E1),
    buttonTextColor: Color(0xDD000000),
    cardShadowColor: Color(0x26000000),
    groupHeaderColor: Color(0x99FFFFFF),
    groupHeaderHoverColor: Color(0x1A9C27B0),
    groupHeaderBorderColor: Color(0xFFAB47BC),
    dropZoneHoverColor: Color(0x1AFF9800),
    dropZoneTextColor: Color(0xFFF57C00),
    floatingActionButtonColor: Color(0xFFF06292),
    appBarGradientStart: Color(0xFFF8BBD0),
    appBarGradientEnd: Color(0xFF4DD0E1),
    folderIconColor: Color(0xFFAB47BC),
    playButtonColor: Color(0xFF4DD0E1),
  );

  static const AppTheme modest = AppTheme(
    name: 'modest',
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
  );

  LinearGradient gradientFromColors(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color cardColorAtIndex(int index) {
    final colors = this == AppTheme.playful
        ? Colors.primaries
        : [const Color(0xFFFFFFFF), const Color(0xFFF5F5F5)];
    return colors[index % colors.length];
  }

  LinearGradient cardGradientAtIndex(int index) {
    if (this == AppTheme.modest) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
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
    if (this == AppTheme.modest) {
      return const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final primary1 = Colors.primaries[hash % Colors.primaries.length];
    final primary2 = Colors.primaries[(hash + 3) % Colors.primaries.length];
    return LinearGradient(
      colors: [primary1.shade200, primary2.shade400],
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
