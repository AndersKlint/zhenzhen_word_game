import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CardListItem extends StatelessWidget {
  final int index;
  final String front;
  final String? back;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final AppTheme theme;

  const CardListItem({
    super.key,
    required this.index,
    required this.front,
    this.back,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = theme.cardGradientAtIndex(index);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        front,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryTextColor,
                        ),
                      ),
                      if (back != null && back!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          back!,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.secondaryTextColor),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
