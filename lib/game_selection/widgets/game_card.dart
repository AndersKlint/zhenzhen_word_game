import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final AppTheme theme;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cardGradient = theme.isModest ? theme.cardGradient : gradient;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildHelpIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpIcon() {
    return Tooltip(
      message: description,
      preferBelow: false,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 5),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
      child: Icon(
        Icons.help_outline,
        size: 28,
        color: theme.secondaryTextColor,
      ),
    );
  }
}
