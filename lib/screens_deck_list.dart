import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'deck_service.dart';
import 'di.dart';
import 'screens_deck_editor.dart';
import 'screens_game_selection.dart';
import 'models.dart';

class DeckListScaffold extends StatefulWidget {
  const DeckListScaffold({super.key});

  @override
  State<DeckListScaffold> createState() => _DeckListScaffoldState();
}

class _DeckListScaffoldState extends State<DeckListScaffold> {
  final deckService = getIt<DeckService>();
  final Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    deckService.addListener(_update);
  }

  @override
  void dispose() {
    deckService.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  Future<void> _createDeck({String? groupId}) async {
    final name = await _ask(context, 'Deck name?');
    if (name != null && name.trim().isNotEmpty) {
      await deckService.addDeck(name.trim(), groupId: groupId);
    }
  }

  Future<void> _createGroup() async {
    final name = await _ask(context, 'Group name?');
    if (name != null && name.trim().isNotEmpty) {
      await deckService.addGroup(name.trim());
    }
  }

  Future<void> _renameGroup(DeckGroup group) async {
    final name = await _ask(context, 'New name?', initialValue: group.name);
    if (name != null && name.trim().isNotEmpty) {
      await deckService.renameGroup(group.id, name.trim());
    }
  }

  Future<void> _deleteGroup(DeckGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          'Delete "${group.name}"? Decks in this group will become ungrouped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await deckService.removeGroup(group.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1C5E5), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Decks',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _createDeck,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add Deck'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _createGroup,
                          icon: const Icon(Icons.folder_outlined, size: 20),
                          label: const Text('Add Group'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black87,
                        ),
                        onSelected: (value) {
                          if (value == 'export') {
                            _showExportDialog();
                          } else if (value == 'import') {
                            _importCollection();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'export',
                            child: Row(
                              children: [
                                Icon(Icons.upload_file),
                                SizedBox(width: 8),
                                Text('Export'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'import',
                            child: Row(
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Import'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildDeckList()),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.cyan.shade300,
                      ),
                      onPressed: deckService.decks.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GameSelectionScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'Go to Games',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckList() {
    final ungroupedDecks = deckService.getUngroupedDecks();
    final groups = deckService.groups;

    if (deckService.decks.isEmpty && groups.isEmpty) {
      return const Center(
        child: Text(
          'No decks yet. Create one!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildUngroupedDropZone(ungroupedDecks),
        for (final group in groups) ...[
          _buildGroupHeader(group),
          if (_expandedGroups.contains(group.id))
            ...deckService
                .getGroupDecks(group.id)
                .map(
                  (deck) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _buildDeckCard(deck),
                  ),
                ),
        ],
      ],
    );
  }

  Widget _buildUngroupedDropZone(List<Deck> ungroupedDecks) {
    return DragTarget<String>(
      onWillAccept: (deckId) {
        if (deckId != null) {
          final deck = deckService.getDeck(deckId);
          return deck.groupId != null;
        }
        return false;
      },
      onAccept: (deckId) {
        deckService.assignDeckToGroup(deckId, null);
      },
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
            color: isHovering ? Colors.orange.shade100 : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: isEmpty
              ? isHovering
                    ? const Center(
                        child: Text(
                          'Drop here to ungroup',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.expand()
              : Column(
                  children: ungroupedDecks
                      .map((deck) => _buildDeckCard(deck))
                      .toList(),
                ),
        );
      },
    );
  }

  Widget _buildGroupHeader(DeckGroup group) {
    final decks = deckService.getGroupDecks(group.id);
    final deckCount = decks.length;
    final isExpanded = _expandedGroups.contains(group.id);

    return DragTarget<String>(
      onWillAccept: (deckId) {
        if (deckId != null) {
          final deck = deckService.getDeck(deckId);
          return deck.groupId != group.id;
        }
        return false;
      },
      onAccept: (deckId) {
        deckService.assignDeckToGroup(deckId, group.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.purple.shade100
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: isHovering
                ? Border.all(color: Colors.purple.shade400, width: 2)
                : null,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedGroups.remove(group.id);
                        } else {
                          _expandedGroups.add(group.id);
                        }
                      });
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.folder, color: Colors.purple.shade400),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${group.name} ($deckCount)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black54,
                            ),
                            onPressed: () => _renameGroup(group),
                            tooltip: 'Rename',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.black54,
                            ),
                            onPressed: () => _deleteGroup(group),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: InkWell(
                    onTap: decks.isEmpty
                        ? null
                        : () {
                            final combinedDeck = _createCombinedDeck(
                              group,
                              decks,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameSelectionScreen(
                                  preselectedDeck: combinedDeck,
                                ),
                              ),
                            );
                          },
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: decks.isEmpty ? Colors.white38 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Deck _createCombinedDeck(DeckGroup group, List<Deck> decks) {
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

  Widget _buildDeckCard(Deck deck) {
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors
                  .primaries[deck.id.hashCode % Colors.primaries.length]
                  .shade100,
              Colors
                  .primaries[(deck.id.hashCode + 3) % Colors.primaries.length]
                  .shade200,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          deck.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final childWhenDragging = Opacity(
      opacity: 0.5,
      child: _buildDeckCardContent(deck),
    );

    final child = _buildDeckCardContent(deck);

    final isDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows);

    if (isDesktop) {
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

  Widget _buildDeckCardContent(Deck deck) {
    final primary1 =
        Colors.primaries[deck.id.hashCode % Colors.primaries.length];
    final primary2 =
        Colors.primaries[(deck.id.hashCode + 3) % Colors.primaries.length];

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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeckEditor(deckId: deck.id),
                    ),
                  ),
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
                        '${deck.words.length} cards',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeckEditor(deckId: deck.id),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete deck?'),
                    content: Text(
                      'Are you sure you want to delete "${deck.name}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  deckService.removeDeck(deck.id);
                }
              },
            ),
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: primary2.shade500,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GameSelectionScreen(preselectedDeck: deck),
                    ),
                  );
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.play_arrow, size: 32, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog() async {
    final selected = <Deck>{};
    bool selectAll = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Export Decks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  dense: true,
                  title: const Text('Select All'),
                  value: selectAll,
                  onChanged: (val) {
                    setDialogState(() {
                      selectAll = val ?? false;
                      if (selectAll) {
                        selected.addAll(deckService.decks);
                      } else {
                        selected.clear();
                      }
                    });
                  },
                ),
                const Divider(),
                for (final d in deckService.getUngroupedDecks())
                  CheckboxListTile(
                    dense: true,
                    title: Text(d.name),
                    value: selected.contains(d),
                    onChanged: (val) => setDialogState(
                      () => val! ? selected.add(d) : selected.remove(d),
                    ),
                  ),
                for (final group in deckService.groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  for (final d in deckService.getGroupDecks(group.id))
                    CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                      ),
                      title: Text(d.name),
                      value: selected.contains(d),
                      onChanged: (val) => setDialogState(
                        () => val! ? selected.add(d) : selected.remove(d),
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await _exportSelected(selected);
                    },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportSelected(Set<Deck> selected) async {
    final json = deckService.exportCollection(selected);

    String? outputPath;
    if (kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Collection',
        fileName: 'zhenzhen_flashcard_collection.json',
        bytes: Uint8List.fromList(json.codeUnits),
      );
    } else {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Collection',
        fileName: 'zhenzhen_flashcard_collection.json',
      );
      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(json);
      }
    }

    if (outputPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${selected.length} deck(s)')),
      );
    }
  }

  Future<void> _importCollection() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Collection',
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    String json;

    if (kIsWeb) {
      json = String.fromCharCodes(file.bytes!);
    } else {
      json = await File(file.path!).readAsString();
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;

      final importedGroups =
          (data['groups'] as List?)
              ?.map((e) => DeckGroup.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [];

      final oldToNewGroupId = <String, String>{};
      for (final group in importedGroups) {
        final existing = deckService.getGroupByName(group.name);
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
        if (deckService.getDeckByName(deck.name, groupId: newGroupId) != null) {
          conflicts.add((deck, newGroupId));
        }
      }

      if (conflicts.isEmpty) {
        final importResult = await deckService.importCollection(
          json,
          onConflict: (_, __) => ConflictResolution.skip,
        );
        if (mounted) {
          _showImportResult(importResult);
        }
      } else {
        await _showConflictResolutionDialog(json, conflicts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _showConflictResolutionDialog(
    String json,
    List<(Deck, String?)> conflicts,
  ) async {
    int currentIndex = 0;
    final resolutions = <(String, String?), ConflictResolution>{};
    bool applyToAll = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (currentIndex >= conflicts.length) {
            return const AlertDialog(content: Text('Processing...'));
          }

          final (conflict, groupId) = conflicts[currentIndex];
          final groupName = groupId != null
              ? deckService.getGroup(groupId)?.name ?? 'Unknown Group'
              : null;

          return AlertDialog(
            title: const Text('Duplicate Deck Name'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName != null
                      ? 'A deck named "${conflict.name}" already exists in "$groupName".'
                      : 'An ungrouped deck named "${conflict.name}" already exists.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'What would you like to do?',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Apply to all remaining conflicts'),
                  value: applyToAll,
                  onChanged: (val) => setDialogState(() {
                    applyToAll = val ?? false;
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (applyToAll) {
                    for (final (c, g) in conflicts.sublist(currentIndex)) {
                      resolutions[(c.name, g)] = ConflictResolution.skip;
                    }
                    Navigator.pop(ctx);
                  } else {
                    resolutions[(conflict.name, groupId)] =
                        ConflictResolution.skip;
                    currentIndex++;
                    if (currentIndex >= conflicts.length) {
                      Navigator.pop(ctx);
                    } else {
                      setDialogState(() {});
                    }
                  }
                },
                child: const Text('Skip'),
              ),
              TextButton(
                onPressed: () {
                  if (applyToAll) {
                    for (final (c, g) in conflicts.sublist(currentIndex)) {
                      resolutions[(c.name, g)] = ConflictResolution.rename;
                    }
                    Navigator.pop(ctx);
                  } else {
                    resolutions[(conflict.name, groupId)] =
                        ConflictResolution.rename;
                    currentIndex++;
                    if (currentIndex >= conflicts.length) {
                      Navigator.pop(ctx);
                    } else {
                      setDialogState(() {});
                    }
                  }
                },
                child: const Text('Rename'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (applyToAll) {
                    for (final (c, g) in conflicts.sublist(currentIndex)) {
                      resolutions[(c.name, g)] = ConflictResolution.replace;
                    }
                    Navigator.pop(ctx);
                  } else {
                    resolutions[(conflict.name, groupId)] =
                        ConflictResolution.replace;
                    currentIndex++;
                    if (currentIndex >= conflicts.length) {
                      Navigator.pop(ctx);
                    } else {
                      setDialogState(() {});
                    }
                  }
                },
                child: const Text('Replace'),
              ),
            ],
          );
        },
      ),
    );

    final importResult = await deckService.importCollection(
      json,
      onConflict: (deckName, groupId) =>
          resolutions[(deckName, groupId)] ?? ConflictResolution.skip,
    );

    if (mounted) {
      _showImportResult(importResult);
    }
  }

  void _showImportResult(ImportResult result) {
    final parts = <String>[];
    if (result.decksImported > 0) {
      parts.add('${result.decksImported} imported');
    }
    if (result.decksReplaced > 0) {
      parts.add('${result.decksReplaced} replaced');
    }
    if (result.decksRenamed > 0) {
      parts.add('${result.decksRenamed} renamed');
    }
    if (result.decksSkipped > 0) {
      parts.add('${result.decksSkipped} skipped');
    }
    if (result.groupsMerged > 0) {
      parts.add('${result.groupsMerged} groups merged');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          parts.isEmpty
              ? 'No changes made'
              : 'Import complete: ${parts.join(', ')}',
        ),
      ),
    );
  }

  Future<String?> _ask(
    BuildContext context,
    String prompt, {
    String? initialValue,
  }) async {
    final ctrl = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(prompt),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
