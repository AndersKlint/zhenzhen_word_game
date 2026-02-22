import 'package:flutter/material.dart';

class DeckListAppBar extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final String title;
  final String exportText;
  final String importText;
  final String currentLanguageText;
  final VoidCallback onToggleLanguage;

  const DeckListAppBar({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.title,
    required this.exportText,
    required this.importText,
    required this.currentLanguageText,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                if (value == 'export') {
                  onExport();
                } else if (value == 'import') {
                  onImport();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file),
                      const SizedBox(width: 8),
                      Text(exportText),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      const Icon(Icons.download),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onToggleLanguage,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              currentLanguageText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
