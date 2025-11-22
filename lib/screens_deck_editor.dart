import 'package:flutter/material.dart';
import 'deck_service.dart';
import 'di.dart';
import 'models.dart';

class DeckEditor extends StatefulWidget {
  final String deckId;
  const DeckEditor({super.key, required this.deckId});

  @override
  State<DeckEditor> createState() => _DeckEditorState();
}

class _DeckEditorState extends State<DeckEditor> {
  final deckService = getIt<DeckService>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWord(String word) {
    final trimmed = word.trim();
    if (trimmed.isNotEmpty) {
      deckService.addWord(widget.deckId, trimmed);
      _controller.clear();
      _focusNode.requestFocus();
      setState(() {}); // refresh UI
    }
  }

  void _removeWord(int index) {
    deckService.removeWord(widget.deckId, index);
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final deck = deckService.getDeck(widget.deckId);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Edit Deck: ${deck.name}',
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD0), // soft pink
              Color(0xFF4DD0E1), // turquoise
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Remove the old title SafeArea text since the AppBar now provides it
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                itemCount: deck.words.length,
                itemBuilder: (_, i) {
                  final word = deck.words[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors
                              .primaries[i % Colors.primaries.length]
                              .shade100,
                          Colors
                              .primaries[(i + 3) % Colors.primaries.length]
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            word,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black87),
                          onPressed: () => _removeWord(i),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.black26),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: _addWord,
                      decoration: const InputDecoration(
                        hintText: 'Add a new word',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _addWord(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
