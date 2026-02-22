import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DeckListAppBar extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onToggleTheme;
  final String title;
  final String exportText;
  final String importText;
  final String themeText;
  final String currentLanguageText;
  final VoidCallback onToggleLanguage;
  final AppTheme theme;

  const DeckListAppBar({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onToggleTheme,
    required this.title,
    required this.exportText,
    required this.importText,
    required this.themeText,
    required this.currentLanguageText,
    required this.onToggleLanguage,
    required this.theme,
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
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.primaryTextColor),
              onSelected: (value) {
                if (value == 'export') {
                  onExport();
                } else if (value == 'import') {
                  onImport();
                } else if (value == 'theme') {
                  onToggleTheme();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(
                        theme.isPlayful ? Icons.brush : Icons.palette,
                        color: theme.primaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(themeText),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: theme.primaryTextColor),
                      const SizedBox(width: 8),
                      Text(exportText),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: theme.primaryTextColor),
                      const SizedBox(width: 8),
                      Text(importText),
                    ],
                  ),
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
