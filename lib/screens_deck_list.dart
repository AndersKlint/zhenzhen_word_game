import 'package:flutter/material.dart';
import 'deck_service.dart';
import 'di.dart';
import 'screens_deck_editor.dart';
import 'screens_game_selection.dart';

class DeckListScaffold extends StatefulWidget {
  const DeckListScaffold({super.key});

  @override
  State<DeckListScaffold> createState() => _DeckListScaffoldState();
}

class _DeckListScaffoldState extends State<DeckListScaffold> {
  final deckService = getIt<DeckService>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE1C5E5), // softer pink-purple
              Color(0xFF80DEEA), // turquoise
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Your Decks',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount:
                      deckService.decks.length + 1, // +1 for add deck button
                  itemBuilder: (context, index) {
                    if (index < deckService.decks.length) {
                      final deck = deckService.decks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDeckCard(deck),
                      );
                    } else {
                      // Add Deck button at the bottom
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: Colors.pink.shade200,
                            ),
                            onPressed: () async {
                              final name = await _ask(context, 'Deck name?');
                              if (name != null && name.trim().isNotEmpty) {
                                await deckService.addDeck(name.trim());
                              }
                            },
                            child: const Text(
                              '+ Add Deck',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              // Play button at bottom
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
                        'Play',
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

  Widget _buildDeckCard(deck) {
    return Container(
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
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeckEditor(deckId: deck.id)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    '${deck.words.length} words',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeckEditor(deckId: deck.id)),
              );
            },
          ),
          // Remove button
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
        ],
      ),
    );
  }

  Future<String?> _ask(BuildContext context, String prompt) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(prompt),
        content: TextField(controller: ctrl),
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
