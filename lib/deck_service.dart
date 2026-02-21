import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ImportResult {
  final int decksImported;
  final int decksSkipped;
  final int decksReplaced;
  final int decksRenamed;
  final int groupsMerged;

  ImportResult({
    required this.decksImported,
    required this.decksSkipped,
    required this.decksReplaced,
    required this.decksRenamed,
    required this.groupsMerged,
  });
}

enum ConflictResolution { replace, skip, rename }

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

  DeckGroup? getGroupByName(String name) {
    try {
      return groups.firstWhere((g) => g.name == name);
    } catch (_) {
      return null;
    }
  }

  Deck? getDeckByName(String name, {String? groupId}) {
    try {
      return decks.firstWhere((d) => d.name == name && d.groupId == groupId);
    } catch (_) {
      return null;
    }
  }

  String _findAvailableName(String baseName, {String? groupId}) {
    var name = baseName;
    var suffix = 1;
    while (getDeckByName(name, groupId: groupId) != null) {
      final match = RegExp(r'^(.+?)\s*\((\d+)\)$').firstMatch(baseName);
      if (match != null) {
        name = '${match.group(1)} (${suffix})';
      } else {
        name = '$baseName ($suffix)';
      }
      suffix++;
    }
    return name;
  }

  String exportCollection(Set<Deck> selectedDecks) {
    final groupIdsToExport = <String>{};
    for (final deck in selectedDecks) {
      if (deck.groupId != null) {
        groupIdsToExport.add(deck.groupId!);
      }
    }

    final exportedGroups = groups
        .where((g) => groupIdsToExport.contains(g.id))
        .map((g) => g.toJson())
        .toList();

    final exportedDecks = selectedDecks.map((d) => d.toJson()).toList();

    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'groups': exportedGroups,
      'decks': exportedDecks,
    });
  }

  Future<ImportResult> importCollection(
    String json, {
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
  }) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final version = data['version'] as int?;
    if (version != 1) {
      throw FormatException('Unsupported export version: $version');
    }

    final importedGroups = (data['groups'] as List)
        .map((e) => DeckGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final importedDecks = (data['decks'] as List)
        .map((e) => Deck.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final oldToNewGroupId = <String, String>{};
    int groupsMerged = 0;

    for (final importedGroup in importedGroups) {
      final existing = getGroupByName(importedGroup.name);
      if (existing != null) {
        oldToNewGroupId[importedGroup.id] = existing.id;
        groupsMerged++;
      } else {
        final newId = _id();
        oldToNewGroupId[importedGroup.id] = newId;
        groups.add(DeckGroup(id: newId, name: importedGroup.name));
      }
    }

    int decksImported = 0;
    int decksSkipped = 0;
    int decksReplaced = 0;
    int decksRenamed = 0;

    for (final importedDeck in importedDecks) {
      final newGroupId = importedDeck.groupId != null
          ? oldToNewGroupId[importedDeck.groupId]
          : null;

      final existing = getDeckByName(importedDeck.name, groupId: newGroupId);

      String deckName = importedDeck.name;

      if (existing != null) {
        final resolution = onConflict(importedDeck.name, newGroupId);
        if (resolution == ConflictResolution.skip) {
          decksSkipped++;
          continue;
        } else if (resolution == ConflictResolution.replace) {
          decks.remove(existing);
          decksReplaced++;
        } else if (resolution == ConflictResolution.rename) {
          deckName = _findAvailableName(importedDeck.name, groupId: newGroupId);
          decksRenamed++;
        }
      }

      final newId = _id();

      decks.add(
        Deck(
          id: newId,
          name: deckName,
          words: importedDeck.words,
          backs: importedDeck.backs,
          groupId: newGroupId,
        ),
      );
      decksImported++;
    }

    await _save();
    notifyListeners();

    return ImportResult(
      decksImported: decksImported,
      decksSkipped: decksSkipped,
      decksReplaced: decksReplaced,
      groupsMerged: groupsMerged,
      decksRenamed: decksRenamed,
    );
  }
}
