import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;
  final String cardCountText;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
    required this.cardCountText,
  });

  @override
  Widget build(BuildContext context) {
    final primary1 =
        Colors.primaries[deck.id.hashCode % Colors.primaries.length];
    final primary2 =
        Colors.primaries[(deck.id.hashCode + 3) % Colors.primaries.length];

    return _buildDraggable(_buildCardContent(primary1, primary2), primary1);
  }

  Widget _buildDraggable(Widget child, MaterialColor primary1) {
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary1.shade100, primary1.shade200],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          deck.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildCardContent(MaterialColor primary1, MaterialColor primary2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary1.shade100, primary2.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardCountText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: onDelete,
            ),
            _buildPlayButton(primary2),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(MaterialColor primary2) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: primary2.shade500,
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
        child: const Center(
          child: Icon(Icons.play_arrow, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
