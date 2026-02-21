import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class DeckService extends ChangeNotifier {
  List<Deck> decks = [];
  List<DeckGroup> groups = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('decks');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      decks = list
          .map((e) => Deck.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final groupsRaw = prefs.getString('groups');
    if (groupsRaw != null) {
      final groupsList = jsonDecode(groupsRaw) as List;
      groups = groupsList
          .map((e) => DeckGroup.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'decks',
      jsonEncode(decks.map((d) => d.toJson()).toList()),
    );
    await prefs.setString(
      'groups',
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
  }

  String _id() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(999).toString();

  Future<void> addDeck(String name, {String? groupId}) async {
    decks.add(Deck(id: _id(), name: name, groupId: groupId));
    await _save();
    notifyListeners();
  }

  Future<void> removeDeck(String id) async {
    decks.removeWhere((d) => d.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addWord(String deckId, String word, {String? back}) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.words.add(word);
    if (back != null && back.isNotEmpty) {
      deck.setBack(deck.words.length - 1, back);
    }
    await _save();
    notifyListeners();
  }

  Future<void> removeWord(String deckId, int idx) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.words.removeAt(idx);
    final newBacks = <int, String>{};
    for (final entry in deck.backs.entries) {
      if (entry.key < idx) {
        newBacks[entry.key] = entry.value;
      } else if (entry.key > idx) {
        newBacks[entry.key - 1] = entry.value;
      }
    }
    deck.backs = newBacks;
    await _save();
    notifyListeners();
  }

  Future<void> updateBack(String deckId, int idx, String? back) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.setBack(idx, back);
    await _save();
    notifyListeners();
  }

  Future<void> updateWord(String deckId, int idx, String word) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.words[idx] = word;
    await _save();
    notifyListeners();
  }

  Future<void> addGroup(String name) async {
    groups.add(DeckGroup(id: _id(), name: name));
    await _save();
    notifyListeners();
  }

  Future<void> removeGroup(String id) async {
    groups.removeWhere((g) => g.id == id);
    for (final deck in decks) {
      if (deck.groupId == id) {
        deck.groupId = null;
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> renameGroup(String id, String newName) async {
    final group = groups.firstWhere((g) => g.id == id);
    group.name = newName;
    await _save();
    notifyListeners();
  }

  Future<void> assignDeckToGroup(String deckId, String? groupId) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.groupId = groupId;
    await _save();
    notifyListeners();
  }

  List<Deck> getGroupDecks(String groupId) =>
      decks.where((d) => d.groupId == groupId).toList();

  List<Deck> getUngroupedDecks() =>
      decks.where((d) => d.groupId == null).toList();

  Deck getDeck(String id) => decks.firstWhere((d) => d.id == id);

  DeckGroup? getGroup(String id) {
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
