import 'package:flutter/foundation.dart';
import '../deck_service.dart';
import '../di.dart';
import '../models.dart';

class GameSelectionController extends ChangeNotifier {
  final DeckService _deckService;

  GameSelectionController({DeckService? deckService})
    : _deckService = deckService ?? getIt<DeckService>();

  List<Deck> get ungroupedDecks => _deckService.getUngroupedDecks();

  List<DeckGroup> get groups => _deckService.groups;

  List<Deck> getGroupDecks(String groupId) =>
      _deckService.getGroupDecks(groupId);

  List<Deck> getAllDecks() => _deckService.decks;

  bool hasBackText(Deck deck) => deck.backs.isNotEmpty;
}
