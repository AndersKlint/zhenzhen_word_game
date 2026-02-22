import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final AppTheme theme;

  const EmptyState({super.key, required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 18, color: theme.secondaryTextColor),
      ),
    );
  }
}
