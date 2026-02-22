import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../platform/file_export.dart';
import '../deck_service.dart';
import '../models.dart';

class ImportExportService {
  final DeckService _deckService;

  ImportExportService(this._deckService);

  Future<void> exportSelectedDecks(
    Set<Deck> selectedDecks, {
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    final json = _deckService.exportCollection(selectedDecks);

    if (kIsWeb) {
      await _exportWeb(json, selectedDecks.length, onSuccess);
    } else {
      await _exportNative(json, selectedDecks.length, onSuccess);
    }
  }

  Future<void> _exportWeb(
    String json,
    int count,
    void Function(String) onSuccess,
  ) async {
    final fileName = 'zhenzhen_flashcard_collection.json';
    final finalName = fileName.endsWith('.json') ? fileName : '$fileName.json';
    final bytes = Uint8List.fromList(utf8.encode(json));
    await exportFileWeb(bytes, finalName);
    onSuccess('Exported $count decks');
  }

  Future<void> _exportNative(
    String json,
    int count,
    void Function(String) onSuccess,
  ) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Collection',
      fileName: 'zhenzhen_flashcard_collection.json',
    );
    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(json);
      onSuccess('Exported $count decks');
    }
  }

  Future<ImportResult?> importCollection({
    required void Function(String) onError,
    required ConflictResolution Function(String deckName, String? groupId)
    onConflict,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Collection',
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    String json;

    if (kIsWeb) {
      json = utf8.decode(file.bytes!);
    } else {
      json = await File(file.path!).readAsString();
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final conflicts = _detectConflicts(data);

      if (conflicts.isEmpty) {
        return await _deckService.importCollection(
          json,
          onConflict: (_, __) => ConflictResolution.skip,
        );
      } else {
        return await _deckService.importCollection(
          json,
          onConflict: onConflict,
        );
      }
    } catch (e) {
      onError(e.toString());
      return null;
    }
  }

  List<(Deck, String?)> _detectConflicts(Map<String, dynamic> data) {
    final importedGroups =
        (data['groups'] as List?)
            ?.map((e) => DeckGroup.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    final oldToNewGroupId = <String, String>{};
    for (final group in importedGroups) {
      final existing = _deckService.getGroupByName(group.name);
      if (existing != null) {
        oldToNewGroupId[group.id] = existing.id;
      } else {
        oldToNewGroupId[group.id] = group.id;
      }
    }

    final importedDecks = (data['decks'] as List)
        .map((e) => Deck.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final conflicts = <(Deck, String?)>[];
    for (final deck in importedDecks) {
      final newGroupId = deck.groupId != null
          ? oldToNewGroupId[deck.groupId]
          : null;
      if (_deckService.getDeckByName(deck.name, groupId: newGroupId) != null) {
        conflicts.add((deck, newGroupId));
      }
    }
    return conflicts;
  }

  Map<String, dynamic> parseImportJson(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }
}
