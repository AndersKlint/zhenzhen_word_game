import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../appbar.dart';
import '../di.dart';
import '../theme/theme_service.dart';
import '../theme/app_theme.dart';
import 'deck_editor_controller.dart';
import 'widgets/card_list_item.dart';
import 'widgets/card_input_form.dart';
import 'widgets/group_selector.dart';
import 'widgets/edit_card_dialog.dart';

class DeckEditorScreen extends StatefulWidget {
  final String deckId;

  const DeckEditorScreen({super.key, required this.deckId});

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  late final DeckEditorController _controller;
  late final ThemeService _themeService;
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _frontFocusNode = FocusNode();
  final _backFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _themeService = getIt<ThemeService>();
    _controller = DeckEditorController(deckId: widget.deckId);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _frontController.dispose();
    _backController.dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deck = _controller.deck;
    final theme = _themeService.theme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, l10n.editor_title(deck.name), theme: theme),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              GroupSelector(
                groupName: _controller.groupName,
                noGroupText: l10n.editor_noGroup,
                onTap: () => _selectGroup(l10n),
              ),
              Expanded(
                child: deck.words.isEmpty
                    ? Center(
                        child: Text(
                          l10n.editor_addFirstCard,
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.secondaryTextColor,
                          ),
                        ),
                      )
                    : _buildCardList(theme),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.black26),
              CardInputForm(
                frontController: _frontController,
                backController: _backController,
                frontFocusNode: _frontFocusNode,
                backFocusNode: _backFocusNode,
                onAdd: _addWord,
                frontLabel: l10n.editor_front,
                backLabel: l10n.editor_back,
                addButtonLabel: l10n.editor_addCard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardList(AppTheme theme) {
    final deck = _controller.deck;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: deck.words.length,
      itemBuilder: (_, i) {
        return CardListItem(
          index: i,
          front: deck.words[i],
          back: deck.getBack(i),
          onEdit: () => _editWord(i),
          onDelete: () => _removeWord(i),
          theme: theme,
        );
      },
    );
  }

  void _addWord() {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (front.isEmpty) return;

    _controller.addWord(front, back.isNotEmpty ? back : null);
    _frontController.clear();
    _backController.clear();
    _frontFocusNode.requestFocus();
  }

  void _removeWord(int index) {
    _controller.removeWord(index);
  }

  Future<void> _editWord(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final deck = _controller.deck;

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (ctx) => EditCardDialog(
        title: l10n.editor_editCard,
        frontLabel: l10n.editor_front,
        backLabel: l10n.editor_back,
        cancelText: l10n.dialog_cancel,
        saveText: l10n.editor_save,
        initialFront: deck.words[index],
        initialBack: deck.getBack(index) ?? '',
      ),
    );

    if (result != null) {
      await _controller.updateWord(
        index,
        result['front'] ?? '',
        result['back'],
      );
    }
  }

  Future<void> _selectGroup(AppLocalizations l10n) async {
    final currentGroupId = _controller.deck.groupId;

    await showDialog(
      context: context,
      builder: (ctx) => SelectGroupDialog(
        groups: _controller.groups,
        title: l10n.editor_selectGroup,
        noGroupText: l10n.editor_noGroup,
        onGroupSelected: (groupId) {
          if (groupId != currentGroupId) {
            _controller.assignToGroup(groupId);
          }
        },
      ),
    );
  }
}
