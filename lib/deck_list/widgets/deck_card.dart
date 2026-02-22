import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models.dart';
import '../../theme/app_theme.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;
  final String cardCountText;
  final AppTheme theme;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
    required this.cardCountText,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = theme.cardGradientAtIndex(deck.id.hashCode);

    return _buildDraggable(_buildCardContent(gradient), gradient);
  }

  Widget _buildDraggable(Widget child, LinearGradient gradient) {
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          deck.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );

    final childWhenDragging = Opacity(opacity: 0.5, child: child);

    final isMobile =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (!isMobile) {
      return Draggable<String>(
        data: deck.id,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    } else {
      return LongPressDraggable<String>(
        data: deck.id,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    }
  }

  Widget _buildCardContent(LinearGradient gradient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.cardShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: onEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        deck.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardCountText,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.secondaryColor),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.close, color: theme.secondaryColor),
              onPressed: onDelete,
            ),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: theme.playButtonColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: InkWell(
        onTap: onPlay,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Center(
          child: Icon(Icons.play_arrow, size: 32, color: theme.buttonTextColor),
        ),
      ),
    );
  }
}
