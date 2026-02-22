import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isEnabled;
  final AppTheme theme;

  const PlayButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isEnabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: theme.playButtonColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: isEnabled ? onPressed : null,
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.buttonTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
