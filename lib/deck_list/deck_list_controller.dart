import 'package:flutter/foundation.dart';
import '../deck_service.dart';
import '../locale_service.dart';
import '../models.dart';
import 'deck_list_state.dart';

class DeckListController extends ChangeNotifier {
  final DeckService _deckService;
  final LocaleService _localeService;

  DeckListState _state = const DeckListState();
  DeckListState get state => _state;

  DeckListController({
    required DeckService deckService,
    required LocaleService localeService,
  }) : _deckService = deckService,
       _localeService = localeService {
    _deckService.addListener(_onDeckServiceChanged);
    _syncState();
  }

  void _onDeckServiceChanged() {
    _syncState();
  }

  void _syncState() {
    _state = _state.copyWith(
      decks: List.from(_deckService.decks),
      groups: List.from(_deckService.groups),
    );
    notifyListeners();
  }

  Future<void> createDeck(String name, {String? groupId}) async {
    if (name.trim().isEmpty) return;
    await _deckService.addDeck(name.trim(), groupId: groupId);
  }

  Future<void> createGroup(String name) async {
    if (name.trim().isEmpty) return;
    await _deckService.addGroup(name.trim());
  }

  Future<void> renameGroup(String groupId, String newName) async {
    if (newName.trim().isEmpty) return;
    await _deckService.renameGroup(groupId, newName.trim());
  }

  Future<void> deleteGroup(String groupId) async {
    await _deckService.removeGroup(groupId);
  }

  void toggleGroupExpanded(String groupId) {
    _state = _state.toggleGroupExpanded(groupId);
    notifyListeners();
  }

  Future<void> assignDeckToGroup(String deckId, String? groupId) async {
    await _deckService.assignDeckToGroup(deckId, groupId);
  }

  Future<void> deleteDeck(String deckId) async {
    await _deckService.removeDeck(deckId);
  }

  Future<void> toggleLocale() async {
    await _localeService.toggleLocale();
  }

  bool get isEnglish => _localeService.isEnglish;

  List<Deck> getUngroupedDecks() => _deckService.getUngroupedDecks();

  List<Deck> getGroupDecks(String groupId) =>
      _deckService.getGroupDecks(groupId);

  Deck getDeck(String deckId) => _deckService.getDeck(deckId);

  DeckGroup? getGroup(String groupId) => _deckService.getGroup(groupId);

  Deck createCombinedDeck(DeckGroup group, List<Deck> decks) {
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
      id: 'combined_${group.id}',
      name: group.name,
      words: allWords,
      backs: allBacks,
    );
  }

  String exportCollection(Set<Deck> selectedDecks) {
    return _deckService.exportCollection(selectedDecks);
  }

  PreparedImportData prepareImport(
    String content, {
    required String filename,
    required String extension,
  }) {
    return _deckService.prepareImport(
      content,
      filename: filename,
      extension: extension,
    );
  }

  Future<ImportResult> importCollection(
    String json, {
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
  }) async {
    return await _deckService.importCollection(json, onConflict: onConflict);
  }

  Future<ImportResult> importData(
    List<DeckGroup> importedGroups,
    List<Deck> importedDecks, {
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
    Map<String, String>? oldToNewGroupId,
  }) async {
    return await _deckService.importData(
      importedGroups,
      importedDecks,
      onConflict: onConflict,
      oldToNewGroupId: oldToNewGroupId,
    );
  }

  @override
  void dispose() {
    _deckService.removeListener(_onDeckServiceChanged);
    super.dispose();
  }
}
