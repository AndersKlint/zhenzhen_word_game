import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../deck_service.dart';
import '../di.dart';
import '../locale_service.dart';
import '../theme/theme_service.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../deck_editor/deck_editor_screen.dart';
import '../game_selection/game_selection_screen.dart';
import '../platform/file_export.dart';
import 'deck_list_controller.dart';
import 'widgets/deck_card.dart';
import 'widgets/group_header.dart';
import 'widgets/ungrouped_drop_zone.dart';
import 'widgets/deck_list_app_bar.dart';
import 'widgets/play_button.dart';
import 'widgets/empty_state.dart';
import 'widgets/dialogs.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  late final DeckListController _controller;
  late final ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = getIt<ThemeService>();
    _controller = DeckListController(
      deckService: getIt<DeckService>(),
      localeService: getIt<LocaleService>(),
    );
    _controller.addListener(_onControllerChanged);
    _themeService.addListener(_onThemeChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _themeService.removeListener(_onThemeChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = _themeService.theme;

    return Scaffold(
      floatingActionButton: _buildFab(l10n, theme),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              DeckListAppBar(
                onExport: () => _showExportDialog(l10n),
                onImport: () => _importCollection(l10n),
                onSelectTheme: (mode) => _themeService.setMode(mode),
                title: l10n.deckList_title,
                exportText: l10n.export_button,
                importText: l10n.import_title,
                themesTitle: l10n.themes_title,
                playfulThemeText: l10n.theme_playful,
                minimalisticThemeText: l10n.theme_minimalistic,
                modernThemeText: l10n.theme_modern,
                darkThemeText: l10n.theme_dark,
                currentLanguageText: _controller.isEnglish
                    ? l10n.lang_chinese
                    : l10n.lang_english,
                onToggleLanguage: () => _controller.toggleLocale(),
                theme: theme,
                currentThemeMode: _themeService.mode,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildDeckList(l10n, theme)),
              PlayButton(
                onPressed: () => _navigateToGameSelection(),
                buttonText: l10n.deckList_goToGames,
                isEnabled: _controller.state.decks.isNotEmpty,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab(AppLocalizations l10n, AppTheme theme) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, -8),
      onSelected: (value) {
        if (value == 'deck') {
          _createDeck(l10n);
        } else if (value == 'group') {
          _createGroup(l10n);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'deck',
          child: Row(
            children: [
              Icon(Icons.add, color: theme.accentColor),
              const SizedBox(width: 12),
              Text(l10n.deckList_addDeck),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'group',
          child: Row(
            children: [
              Icon(Icons.folder_outlined, color: theme.folderIconColor),
              const SizedBox(width: 12),
              Text(l10n.deckList_addGroup),
            ],
          ),
        ),
      ],
      child: FloatingActionButton(
        onPressed: null,
        backgroundColor: theme.floatingActionButtonColor,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: theme.buttonTextColor, size: 28),
      ),
    );
  }

  Widget _buildDeckList(AppLocalizations l10n, AppTheme theme) {
    final state = _controller.state;
    final ungroupedDecks = _controller.getUngroupedDecks();
    final groups = state.groups;

    if (state.isEmpty) {
      return EmptyState(message: l10n.deckList_noDecks, theme: theme);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        UngroupedDropZone(
          ungroupedDecks: ungroupedDecks,
          canAcceptDeck: (deckId) {
            final deck = _controller.getDeck(deckId);
            return deck.groupId != null;
          },
          onDeckDropped: (deckId) {
            _controller.assignDeckToGroup(deckId, null);
          },
          dropToUngroupText: l10n.deckList_dropToUngroup,
          onEditDeck: (deck) => _navigateToDeckEditor(deck.id),
          onDeleteDeck: (deck) => _deleteDeck(deck, l10n),
          onPlayDeck: (deck) =>
              _navigateToGameSelection(preselectedDecks: [deck]),
          theme: theme,
        ),
        for (final group in groups) ...[_buildGroupSection(group, l10n, theme)],
      ],
    );
  }

  Widget _buildGroupSection(
    DeckGroup group,
    AppLocalizations l10n,
    AppTheme theme,
  ) {
    final decks = _controller.getGroupDecks(group.id);
    final isExpanded = _controller.state.isGroupExpanded(group.id);

    return Column(
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            final deck = _controller.getDeck(details.data);
            return deck.groupId != group.id;
          },
          onAcceptWithDetails: (details) {
            _controller.assignDeckToGroup(details.data, group.id);
          },
          builder: (context, candidateData, rejectedData) {
            return GroupHeader(
              group: group,
              deckCount: decks.length,
              isExpanded: isExpanded,
              isHovering: candidateData.isNotEmpty,
              onToggleExpand: () => _controller.toggleGroupExpanded(group.id),
              onRename: () => _renameGroup(group, l10n),
              onDelete: () => _deleteGroup(group, l10n),
              onPlay: () => _playGroup(group, decks),
              renameTooltip: l10n.tooltip_rename,
              deleteTooltip: l10n.tooltip_delete,
              canPlay: decks.isNotEmpty,
              theme: theme,
            );
          },
        ),
        if (isExpanded)
          ...decks.map(
            (deck) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: DeckCard(
                deck: deck,
                onEdit: () => _navigateToDeckEditor(deck.id),
                onDelete: () => _deleteDeck(deck, l10n),
                onPlay: () =>
                    _navigateToGameSelection(preselectedDecks: [deck]),
                cardCountText: l10n.deckList_cards(deck.words.length),
                theme: theme,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _createDeck(AppLocalizations l10n) async {
    final name = await _ask(context, l10n.dialog_deckName);
    if (name != null) {
      await _controller.createDeck(name);
    }
  }

  Future<void> _createGroup(AppLocalizations l10n) async {
    final name = await _ask(context, l10n.dialog_groupName);
    if (name != null) {
      await _controller.createGroup(name);
    }
  }

  Future<void> _renameGroup(DeckGroup group, AppLocalizations l10n) async {
    final name = await _ask(
      context,
      l10n.dialog_newName,
      initialValue: group.name,
    );
    if (name != null) {
      await _controller.renameGroup(group.id, name);
    }
  }

  Future<void> _deleteGroup(DeckGroup group, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: l10n.deleteGroup_title,
        message: l10n.deleteGroup_message(group.name),
        cancelText: l10n.dialog_cancel,
        deleteText: l10n.dialog_delete,
      ),
    );
    if (confirmed == true) {
      await _controller.deleteGroup(group.id);
    }
  }

  Future<void> _deleteDeck(Deck deck, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        title: l10n.deleteDeck_title,
        message: l10n.deleteDeck_message(deck.name),
        cancelText: l10n.dialog_cancel,
        deleteText: l10n.dialog_delete,
      ),
    );
    if (confirmed == true) {
      await _controller.deleteDeck(deck.id);
    }
  }

  void _playGroup(DeckGroup group, List<Deck> decks) {
    _navigateToGameSelection(preselectedDecks: decks);
  }

  void _navigateToDeckEditor(String deckId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeckEditorScreen(deckId: deckId)),
    );
  }

  void _navigateToGameSelection({List<Deck> preselectedDecks = const []}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameSelectionScreen(
          preselectedDecks: preselectedDecks,
          theme: _themeService.theme,
        ),
      ),
    );
  }

  Future<void> _showExportDialog(AppLocalizations l10n) async {
    await showDialog(
      context: context,
      builder: (ctx) => ExportDialog(
        ungroupedDecks: _controller.getUngroupedDecks(),
        groups: _controller.state.groups,
        getGroupDecks: _controller.getGroupDecks,
        onExport: (selected) => _exportSelected(selected, l10n),
        title: l10n.export_title,
        selectAllText: l10n.export_selectAll,
        cancelButtonText: l10n.dialog_cancel,
        exportButtonText: l10n.export_button,
      ),
    );
  }

  Future<void> _exportSelected(
    Set<Deck> selected,
    AppLocalizations l10n,
  ) async {
    final json = _controller.exportCollection(selected);

    if (kIsWeb) {
      final fileName = 'zhenzhen_flashcard_collection.json';
      final bytes = Uint8List.fromList(utf8.encode(json));
      await exportFileWeb(bytes, fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.export_success(selected.length))),
        );
      }
      return;
    }

    final outputPath = await FilePicker.saveFile(
      dialogTitle: l10n.export_title,
      fileName: 'zhenzhen_flashcard_collection.json',
    );
    if (outputPath != null) {
      final filePath = ensureJsonExtension(outputPath);
      final file = File(filePath);
      await file.writeAsString(json);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.export_success(selected.length))),
        );
      }
    }
  }

  Future<void> _importCollection(AppLocalizations l10n) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: l10n.import_title,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final extension = (file.extension ?? '').toLowerCase();
    final content = kIsWeb
        ? utf8.decode(file.bytes ?? Uint8List(0))
        : await File(file.path!).readAsString();

    try {
      final preparedImport = _controller.prepareImport(
        content,
        filename: file.name,
        extension: extension,
      );

      if (!preparedImport.hasConflicts) {
        final importResult = await _controller.importData(
          preparedImport.importedGroups,
          preparedImport.importedDecks,
          onConflict: (_, __) => ConflictResolution.skip,
          oldToNewGroupId: preparedImport.oldToNewGroupId,
        );
        if (mounted) {
          _showImportResult(importResult, l10n);
        }
      } else {
        await _showConflictResolutionDialog(preparedImport, l10n);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.import_failed(e.toString()))),
        );
      }
    }
  }

  Future<void> _showConflictResolutionDialog(
    PreparedImportData preparedImport,
    AppLocalizations l10n,
  ) async {
    final resolutions =
        await showDialog<Map<(String, String?), ConflictResolution>>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ConflictResolutionDialog(
            conflicts: preparedImport.conflicts,
            getGroupName: (groupId) => _controller.getGroup(groupId)?.name,
            title: l10n.conflict_title,
            messageGrouped: l10n.conflict_messageGrouped('{deck}', '{group}'),
            messageUngrouped: l10n.conflict_messageUngrouped('{deck}'),
            whatToDoText: l10n.conflict_whatToDo,
            applyToAllText: l10n.conflict_applyToAll,
            skipText: l10n.dialog_skip,
            renameText: l10n.dialog_rename,
            replaceText: l10n.dialog_replace,
          ),
        );

    if (resolutions != null) {
      final importResult = await _controller.importData(
        preparedImport.importedGroups,
        preparedImport.importedDecks,
        onConflict: (deckName, groupId) =>
            resolutions[(deckName, groupId)] ?? ConflictResolution.skip,
        oldToNewGroupId: preparedImport.oldToNewGroupId,
      );
      if (mounted) {
        _showImportResult(importResult, l10n);
      }
    }
  }

  void _showImportResult(ImportResult result, AppLocalizations l10n) {
    final parts = <String>[];
    if (result.decksImported > 0) {
      parts.add(l10n.importResult_imported(result.decksImported));
    }
    if (result.decksReplaced > 0) {
      parts.add(l10n.importResult_replaced(result.decksReplaced));
    }
    if (result.decksRenamed > 0) {
      parts.add(l10n.importResult_renamed(result.decksRenamed));
    }
    if (result.decksSkipped > 0) {
      parts.add(l10n.importResult_skipped(result.decksSkipped));
    }
    if (result.groupsMerged > 0) {
      parts.add(l10n.importResult_groupsMerged(result.groupsMerged));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          parts.isEmpty
              ? l10n.importResult_noChanges
              : l10n.importResult_complete(parts.join(', ')),
        ),
      ),
    );
  }

  Future<String?> _ask(
    BuildContext context,
    String prompt, {
    String? initialValue,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (_) => TextInputDialog(
        title: prompt,
        initialValue: initialValue,
        cancelText: l10n.dialog_cancel,
        okText: l10n.dialog_ok,
      ),
    );
  }
}
