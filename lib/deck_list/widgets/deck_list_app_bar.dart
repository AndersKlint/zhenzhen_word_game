import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DeckListAppBar extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final void Function(AppThemeMode mode) onSelectTheme;
  final String title;
  final String exportText;
  final String importText;
  final String themesTitle;
  final String playfulThemeText;
  final String minimalisticThemeText;
  final String modernThemeText;
  final String darkThemeText;
  final String currentLanguageText;
  final VoidCallback onToggleLanguage;
  final AppTheme theme;
  final AppThemeMode currentThemeMode;

  const DeckListAppBar({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onSelectTheme,
    required this.title,
    required this.exportText,
    required this.importText,
    required this.themesTitle,
    required this.playfulThemeText,
    required this.minimalisticThemeText,
    required this.modernThemeText,
    required this.darkThemeText,
    required this.currentLanguageText,
    required this.onToggleLanguage,
    required this.theme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.groupHeaderColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MenuAnchor(
              builder: (context, controller, child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: Icon(Icons.more_vert, color: theme.primaryTextColor),
                );
              },
              menuChildren: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: currentThemeMode == AppThemeMode.playful
                          ? null
                          : () => onSelectTheme(AppThemeMode.playful),
                      leadingIcon: currentThemeMode == AppThemeMode.playful
                          ? Icon(Icons.check, color: theme.primaryColor)
                          : null,
                      child: Text(playfulThemeText),
                    ),
                    MenuItemButton(
                      onPressed: currentThemeMode == AppThemeMode.minimalistic
                          ? null
                          : () => onSelectTheme(AppThemeMode.minimalistic),
                      leadingIcon: currentThemeMode == AppThemeMode.minimalistic
                          ? Icon(Icons.check, color: theme.primaryColor)
                          : null,
                      child: Text(minimalisticThemeText),
                    ),
                    MenuItemButton(
                      onPressed: currentThemeMode == AppThemeMode.modern
                          ? null
                          : () => onSelectTheme(AppThemeMode.modern),
                      leadingIcon: currentThemeMode == AppThemeMode.modern
                          ? Icon(Icons.check, color: theme.primaryColor)
                          : null,
                      child: Text(modernThemeText),
                    ),
                    MenuItemButton(
                      onPressed: currentThemeMode == AppThemeMode.dark
                          ? null
                          : () => onSelectTheme(AppThemeMode.dark),
                      leadingIcon: currentThemeMode == AppThemeMode.dark
                          ? Icon(Icons.check, color: theme.primaryColor)
                          : null,
                      child: Text(darkThemeText),
                    ),
                  ],
                  child: Row(
                    children: [
                      Icon(Icons.palette, color: theme.primaryTextColor),
                      const SizedBox(width: 8),
                      Text(themesTitle),
                    ],
                  ),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: onExport,
                  leadingIcon: Icon(
                    Icons.upload_file,
                    color: theme.primaryTextColor,
                  ),
                  child: Text(exportText),
                ),
                MenuItemButton(
                  onPressed: onImport,
                  leadingIcon: Icon(
                    Icons.download,
                    color: theme.primaryTextColor,
                  ),
                  child: Text(importText),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.primaryTextColor,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onToggleLanguage,
            style: TextButton.styleFrom(
              backgroundColor: theme.groupHeaderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              currentLanguageText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
