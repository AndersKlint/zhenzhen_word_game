import 'package:flutter/foundation.dart';
import '../deck_service.dart';
import '../di.dart';
import '../models.dart';

class DeckEditorController extends ChangeNotifier {
  final DeckService _deckService;
  final String deckId;

  DeckEditorController({required this.deckId, DeckService? deckService})
    : _deckService = deckService ?? getIt<DeckService>() {
    _deckService.addListener(_onDeckServiceChanged);
  }

  void _onDeckServiceChanged() {
    notifyListeners();
  }

  Deck get deck => _deckService.getDeck(deckId);

  String? get groupName {
    final groupId = deck.groupId;
    if (groupId == null) return null;
    return _deckService.getGroup(groupId)?.name;
  }

  List<DeckGroup> get groups => _deckService.groups;

  Future<void> addWord(String front, String? back) async {
    if (front.trim().isEmpty) return;
    await _deckService.addWord(
      deckId,
      front.trim(),
      back: (back?.trim().isNotEmpty == true) ? back!.trim() : null,
    );
  }

  Future<void> removeWord(int index) async {
    await _deckService.removeWord(deckId, index);
  }

  Future<void> updateWord(int index, String front, String? back) async {
    await _deckService.updateWord(deckId, index, front.trim());
    await _deckService.updateBack(
      deckId,
      index,
      (back?.trim().isNotEmpty == true) ? back!.trim() : null,
    );
  }

  Future<void> assignToGroup(String? groupId) async {
    await _deckService.assignDeckToGroup(deckId, groupId);
  }

  @override
  void dispose() {
    _deckService.removeListener(_onDeckServiceChanged);
    super.dispose();
  }
}
