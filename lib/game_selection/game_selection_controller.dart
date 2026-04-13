import 'package:flutter/foundation.dart';
import '../deck_service.dart';
import '../models.dart';

class GameSelectionController extends ChangeNotifier {
  final DeckService _deckService;

  GameSelectionController({required DeckService deckService})
    : _deckService = deckService;

  List<Deck> get ungroupedDecks => _deckService.getUngroupedDecks();

  List<DeckGroup> get groups => _deckService.groups;

  List<Deck> getGroupDecks(String groupId) =>
      _deckService.getGroupDecks(groupId);

  bool hasBackText(Deck deck) => deck.hasBackText;

  Deck mergeDecks(List<Deck> decks, {required String name}) {
    final allWords = <String>[];
    final allBacks = <int, String>{};

    for (final deck in decks) {
      final startIndex = allWords.length;
      allWords.addAll(deck.words);
      deck.backs.forEach((idx, back) {
        allBacks[startIndex + idx] = back;
      });
    }

    return Deck(
      id: 'session_${decks.map((deck) => deck.id).join('_')}',
      name: name,
      words: allWords,
      backs: allBacks,
    );
  }
}
