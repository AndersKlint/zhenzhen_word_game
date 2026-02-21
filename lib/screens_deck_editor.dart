import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import 'deck_service.dart';
import 'di.dart';

class DeckEditor extends StatefulWidget {
  final String deckId;
  const DeckEditor({super.key, required this.deckId});

  @override
  State<DeckEditor> createState() => _DeckEditorState();
}

class _DeckEditorState extends State<DeckEditor> {
  final deckService = getIt<DeckService>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _frontFocusNode = FocusNode();
  final _backFocusNode = FocusNode();

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
    super.dispose();
  }

  void _addWord() {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    if (front.isNotEmpty) {
      deckService.addWord(
        widget.deckId,
        front,
        back: back.isNotEmpty ? back : null,
      );
      _frontController.clear();
      _backController.clear();
      _frontFocusNode.requestFocus();
      setState(() {});
    }
  }

  void _removeWord(int index) {
    deckService.removeWord(widget.deckId, index);
    setState(() {});
  }

  void _editWord(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final deck = deckService.getDeck(widget.deckId);
    final currentFront = deck.words[index];
    final currentBack = deck.getBack(index) ?? '';

    final frontCtrl = TextEditingController(text: currentFront);
    final backCtrl = TextEditingController(text: currentBack);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editor_editCard),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontCtrl,
              decoration: InputDecoration(
                labelText: l10n.editor_front,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: backCtrl,
              decoration: InputDecoration(
                labelText: l10n.editor_back,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialog_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editor_save),
          ),
        ],
      ),
    );

    if (result == true) {
      deckService.updateWord(widget.deckId, index, frontCtrl.text.trim());
      deckService.updateBack(
        widget.deckId,
        index,
        backCtrl.text.trim().isEmpty ? null : backCtrl.text.trim(),
      );
      setState(() {});
    }
  }

  Future<void> _selectGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final deck = deckService.getDeck(widget.deckId);
    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.editor_selectGroup),
        children: [
          SimpleDialogOption(
            child: Text(l10n.editor_noGroup),
            onPressed: () => Navigator.pop(ctx, null),
          ),
          for (final group in deckService.groups)
            SimpleDialogOption(
              child: Text(group.name),
              onPressed: () => Navigator.pop(ctx, group.id),
            ),
        ],
      ),
    );
    if (selected != deck.groupId) {
      deckService.assignDeckToGroup(widget.deckId, selected);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deck = deckService.getDeck(widget.deckId);
    final groupName = deck.groupId != null
        ? deckService.getGroup(deck.groupId!)?.name
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, l10n.editor_title(deck.name)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8BBD0), Color(0xFF4DD0E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: InkWell(
                  onTap: _selectGroup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          groupName ?? l10n.editor_noGroup,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: deck.words.isEmpty
                    ? Center(
                        child: Text(
                          l10n.editor_addFirstCard,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: deck.words.length,
                        itemBuilder: (_, i) {
                          final front = deck.words[i];
                          final back = deck.getBack(i);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors
                                      .primaries[i % Colors.primaries.length]
                                      .shade100,
                                  Colors
                                      .primaries[(i + 3) %
                                          Colors.primaries.length]
                                      .shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => _editWord(i),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              front,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (back != null &&
                                                back.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                back,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () => _removeWord(i),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.black26),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _frontController,
                            focusNode: _frontFocusNode,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _backFocusNode.requestFocus(),
                            decoration: InputDecoration(
                              labelText: l10n.editor_front,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _backController,
                            focusNode: _backFocusNode,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _addWord(),
                            decoration: InputDecoration(
                              labelText: l10n.editor_back,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.editor_addCard,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
