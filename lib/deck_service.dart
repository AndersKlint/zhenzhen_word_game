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

class ImportConflict {
  final Deck deck;
  final String? groupId;

  const ImportConflict({required this.deck, required this.groupId});
}

class PreparedImportData {
  final List<DeckGroup> importedGroups;
  final List<Deck> importedDecks;
  final Map<String, String> oldToNewGroupId;
  final List<ImportConflict> conflicts;

  const PreparedImportData({
    required this.importedGroups,
    required this.importedDecks,
    required this.oldToNewGroupId,
    required this.conflicts,
  });

  bool get hasConflicts => conflicts.isNotEmpty;
}

enum ConflictResolution { replace, skip, rename }

class DeckService extends ChangeNotifier {
  static const _decksKey = 'decks';
  static const _groupsKey = 'groups';

  List<Deck> decks = [];
  List<DeckGroup> groups = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_decksKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      decks = list
          .map((e) => Deck.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final groupsRaw = prefs.getString(_groupsKey);
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
      _decksKey,
      jsonEncode(decks.map((d) => d.toJson()).toList()),
    );
    await prefs.setString(
      _groupsKey,
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  String _id() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(999).toString();

  Deck? _findDeckById(String id) {
    for (final deck in decks) {
      if (deck.id == id) {
        return deck;
      }
    }
    return null;
  }

  DeckGroup? _findGroupById(String id) {
    for (final group in groups) {
      if (group.id == id) {
        return group;
      }
    }
    return null;
  }

  Deck _requireDeck(String id) =>
      _findDeckById(id) ?? (throw StateError('Deck not found: $id'));

  DeckGroup _requireGroup(String id) =>
      _findGroupById(id) ?? (throw StateError('Group not found: $id'));

  Future<void> addDeck(String name, {String? groupId}) async {
    decks.add(Deck(id: _id(), name: name, groupId: groupId));
    await _saveAndNotify();
  }

  Future<void> removeDeck(String id) async {
    decks.removeWhere((d) => d.id == id);
    await _saveAndNotify();
  }

  Future<void> addWord(String deckId, String word, {String? back}) async {
    final deck = _requireDeck(deckId);
    deck.words.add(word);
    if (back != null && back.isNotEmpty) {
      deck.setBack(deck.words.length - 1, back);
    }
    await _saveAndNotify();
  }

  Future<void> removeWord(String deckId, int idx) async {
    final deck = _requireDeck(deckId);
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
    await _saveAndNotify();
  }

  Future<void> updateBack(String deckId, int idx, String? back) async {
    final deck = _requireDeck(deckId);
    deck.setBack(idx, back);
    await _saveAndNotify();
  }

  Future<void> updateWord(String deckId, int idx, String word) async {
    final deck = _requireDeck(deckId);
    deck.words[idx] = word;
    await _saveAndNotify();
  }

  Future<void> addGroup(String name) async {
    groups.add(DeckGroup(id: _id(), name: name));
    await _saveAndNotify();
  }

  Future<void> removeGroup(String id) async {
    groups.removeWhere((g) => g.id == id);
    for (final deck in decks) {
      if (deck.groupId == id) {
        deck.groupId = null;
      }
    }
    await _saveAndNotify();
  }

  Future<void> renameGroup(String id, String newName) async {
    final group = _requireGroup(id);
    group.name = newName;
    await _saveAndNotify();
  }

  Future<void> assignDeckToGroup(String deckId, String? groupId) async {
    final deck = _requireDeck(deckId);
    deck.groupId = groupId;
    await _saveAndNotify();
  }

  List<Deck> getGroupDecks(String groupId) =>
      decks.where((d) => d.groupId == groupId).toList();

  List<Deck> getUngroupedDecks() =>
      decks.where((d) => d.groupId == null).toList();

  Deck getDeck(String id) => _requireDeck(id);

  DeckGroup? getGroup(String id) => _findGroupById(id);

  DeckGroup? getGroupByName(String name) {
    for (final group in groups) {
      if (group.name == name) {
        return group;
      }
    }
    return null;
  }

  Deck? getDeckByName(String name, {String? groupId}) {
    for (final deck in decks) {
      if (deck.name == name && deck.groupId == groupId) {
        return deck;
      }
    }
    return null;
  }

  String _findAvailableName(String baseName, {String? groupId}) {
    var name = baseName;
    var suffix = 1;
    while (getDeckByName(name, groupId: groupId) != null) {
      final match = RegExp(r'^(.+?)\s*\((\d+)\)$').firstMatch(baseName);
      if (match != null) {
        name = '${match.group(1)} ($suffix)';
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

    return const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'groups': exportedGroups,
      'decks': exportedDecks,
    });
  }

  PreparedImportData prepareImport(
    String content, {
    required String filename,
    required String extension,
  }) {
    final importedData = switch (extension.toLowerCase()) {
      'csv' => parseLaoziCsv(
        content,
        filename.replaceAll(RegExp(r'\.csv$', caseSensitive: false), ''),
      ),
      _ => _parseImportedJson(content),
    };
    final oldToNewGroupId = _mapExistingGroupIds(importedData.groups);

    return PreparedImportData(
      importedGroups: importedData.groups,
      importedDecks: importedData.decks,
      oldToNewGroupId: oldToNewGroupId,
      conflicts: _findImportConflicts(importedData.decks, oldToNewGroupId),
    );
  }

  ({List<DeckGroup> groups, List<Deck> decks}) _parseImportedJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final importedGroups =
        (data['groups'] as List?)
            ?.map((e) => DeckGroup.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final importedDecks = (data['decks'] as List)
        .map((e) => Deck.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return (groups: importedGroups, decks: importedDecks);
  }

  ({List<DeckGroup> groups, List<Deck> decks}) _parseExportedCollection(
    String json,
  ) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final version = data['version'] as int?;
    if (version != 1) {
      throw FormatException('Unsupported export version: $version');
    }

    return _parseImportedJson(json);
  }

  Map<String, String> _mapExistingGroupIds(List<DeckGroup> importedGroups) {
    final oldToNewGroupId = <String, String>{};
    for (final importedGroup in importedGroups) {
      final existing = getGroupByName(importedGroup.name);
      if (existing != null) {
        oldToNewGroupId[importedGroup.id] = existing.id;
      }
    }
    return oldToNewGroupId;
  }

  List<ImportConflict> _findImportConflicts(
    List<Deck> importedDecks,
    Map<String, String> oldToNewGroupId,
  ) {
    final conflicts = <ImportConflict>[];
    for (final deck in importedDecks) {
      final newGroupId = deck.groupId != null
          ? oldToNewGroupId[deck.groupId]
          : null;
      if (getDeckByName(deck.name, groupId: newGroupId) != null) {
        conflicts.add(ImportConflict(deck: deck, groupId: newGroupId));
      }
    }
    return conflicts;
  }

  List<String> _splitTabSeparatedWithQuotes(String line) {
    final columns = <String>[];
    var current = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < line.length) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes) {
          if (i + 1 < line.length && line[i + 1] == '"') {
            current.write('"');
            i += 2;
            continue;
          }
          inQuotes = false;
        } else {
          inQuotes = true;
        }
        i++;
      } else if (char == '\t' && !inQuotes) {
        columns.add(current.toString());
        current = StringBuffer();
        i++;
      } else {
        current.write(char);
        i++;
      }
    }

    columns.add(current.toString());
    return columns;
  }

  ({List<DeckGroup> groups, List<Deck> decks}) parseLaoziCsv(
    String content,
    String filename,
  ) {
    final lines = content.split('\n');
    if (lines.isEmpty) {
      return (groups: <DeckGroup>[], decks: <Deck>[]);
    }

    final header = _splitTabSeparatedWithQuotes(lines.first);
    final numColumns = header.length;
    if (!header.contains('hanzi') ||
        !header.contains('meaning') ||
        !header.contains('pinyin')) {
      throw const FormatException(
        'Invalid CSV format: missing required columns (hanzi, meaning, pinyin)',
      );
    }
    final hanziIdx = 0;
    final meaningIdx = 1;
    final pinyinIdx = 2;
    final tagsIdx = numColumns - 1;

    final nameToGroup = <String, DeckGroup>{};
    final nameToGroupId = <String, String>{};
    final deckKeyToDeck = <(String, String?), Deck>{};

    void ensureGroup(String name) {
      if (!nameToGroup.containsKey(name)) {
        final id = _id();
        nameToGroup[name] = DeckGroup(id: id, name: name);
        nameToGroupId[name] = id;
      }
    }

    String? extractTag(String tags, String key) {
      final pattern = RegExp('$key:([^\\s]+)');
      final match = pattern.firstMatch(tags);
      if (match == null) return null;
      return Uri.decodeComponent(match.group(1)!);
    }

    List<String> joinMultilineRecords(List<String> lines) {
      final result = <String>[];
      var buffer = StringBuffer();
      var inQuotes = false;
      var pendingNewlines = 0;

      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];

        if (line.trim().isEmpty) {
          if (inQuotes) {
            pendingNewlines++;
          }
          continue;
        }

        var quoteCount = 0;
        for (var j = 0; j < line.length; j++) {
          if (line[j] == '"') {
            quoteCount++;
          }
        }

        if (inQuotes) {
          if (pendingNewlines > 0) {
            buffer.write('\n' * pendingNewlines);
            pendingNewlines = 0;
          } else {
            buffer.write('\n');
          }
          buffer.write(line);
          if (quoteCount % 2 == 1) {
            inQuotes = false;
            result.add(buffer.toString());
            buffer = StringBuffer();
          }
        } else {
          if (quoteCount % 2 == 1) {
            buffer.write(line);
            inQuotes = true;
          } else {
            result.add(line);
          }
        }
      }

      if (buffer.isNotEmpty) {
        result.add(buffer.toString());
      }

      return result;
    }

    final records = joinMultilineRecords(lines);

    for (final line in records) {
      final columns = _splitTabSeparatedWithQuotes(line);

      if (columns.length < numColumns) continue;

      final hanzi = columns[hanziIdx].trim();
      if (hanzi.isEmpty) continue;

      final meaning = meaningIdx < columns.length
          ? columns[meaningIdx].trim()
          : '';
      final pinyin = pinyinIdx < columns.length
          ? columns[pinyinIdx].trim()
          : '';

      String? deckName = filename;
      String? groupName;

      if (tagsIdx >= 0 && tagsIdx < columns.length) {
        final tags = columns[tagsIdx].trim();
        deckName = extractTag(tags, 'deck') ?? filename;
        groupName = extractTag(tags, 'group');
      }

      String? groupId;
      if (groupName != null) {
        ensureGroup(groupName);
        groupId = nameToGroupId[groupName];
      }

      final deckKey = (deckName, groupId);
      var deck = deckKeyToDeck[deckKey];
      if (deck == null) {
        deck = Deck(id: _id(), name: deckName, groupId: groupId);
        deckKeyToDeck[deckKey] = deck;
      }

      final idx = deck.words.length;
      deck.words.add(hanzi);
      final back = pinyin.isNotEmpty ? '$pinyin\n$meaning' : meaning;
      if (back.isNotEmpty) {
        deck.setBack(idx, back);
      }
    }

    return (
      groups: nameToGroup.values.toList(),
      decks: deckKeyToDeck.values.toList(),
    );
  }

  Future<ImportResult> importCollection(
    String json, {
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
  }) async {
    final importedData = _parseExportedCollection(json);
    return importData(
      importedData.groups,
      importedData.decks,
      onConflict: onConflict,
    );
  }

  Future<ImportResult> importData(
    List<DeckGroup> importedGroups,
    List<Deck> importedDecks, {
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
    Map<String, String>? oldToNewGroupId,
  }) async {
    oldToNewGroupId ??= {};
    int groupsMerged = 0;

    for (final importedGroup in importedGroups) {
      if (!oldToNewGroupId.containsKey(importedGroup.id)) {
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
          words: List<String>.from(importedDeck.words),
          backs: Map<int, String>.from(importedDeck.backs),
          groupId: newGroupId,
        ),
      );
      decksImported++;
    }

    await _saveAndNotify();

    return ImportResult(
      decksImported: decksImported,
      decksSkipped: decksSkipped,
      decksReplaced: decksReplaced,
      groupsMerged: groupsMerged,
      decksRenamed: decksRenamed,
    );
  }
}
