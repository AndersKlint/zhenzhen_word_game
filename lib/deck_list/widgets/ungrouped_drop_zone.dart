import 'package:flutter/material.dart';
import '../../models.dart';
import '../../theme/app_theme.dart';
import 'deck_card.dart';

class UngroupedDropZone extends StatelessWidget {
  final List<Deck> ungroupedDecks;
  final bool Function(String deckId) canAcceptDeck;
  final void Function(String deckId) onDeckDropped;
  final String dropToUngroupText;
  final Function(Deck deck) onEditDeck;
  final Function(Deck deck) onDeleteDeck;
  final Function(Deck deck) onPlayDeck;
  final AppTheme theme;

  const UngroupedDropZone({
    super.key,
    required this.ungroupedDecks,
    required this.canAcceptDeck,
    required this.onDeckDropped,
    required this.dropToUngroupText,
    required this.onEditDeck,
    required this.onDeleteDeck,
    required this.onPlayDeck,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        return canAcceptDeck(details.data);
      },
      onAcceptWithDetails: (details) => onDeckDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isEmpty = ungroupedDecks.isEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isEmpty ? (isHovering ? 60 : 24) : null,
          margin: isEmpty && isHovering
              ? const EdgeInsets.only(bottom: 8)
              : null,
          decoration: BoxDecoration(
            color: isHovering ? theme.dropZoneHoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: isEmpty
              ? isHovering
                    ? Center(
                        child: Text(
                          dropToUngroupText,
                          style: TextStyle(
                            color: theme.dropZoneTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.expand()
              : Column(
                  children: ungroupedDecks
                      .map(
                        (deck) => DeckCard(
                          deck: deck,
                          onEdit: () => onEditDeck(deck),
                          onDelete: () => onDeleteDeck(deck),
                          onPlay: () => onPlayDeck(deck),
                          cardCountText: '${deck.words.length} cards',
                          theme: theme,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
