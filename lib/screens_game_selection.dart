import 'package:flutter/material.dart';
import 'package:zhenzhen_word_game/models.dart';
import 'deck_service.dart';
import 'di.dart';
import 'screens_game.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deckService = getIt<DeckService>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD0), // pink
              Color(0xFF4DD0E1), // turquoise
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
                  'Select Game Mode',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildGameCard(
                      context,
                      title: 'Single Deck Mode',
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4DD0E1),
                          Color.fromARGB(255, 242, 196, 253),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck = await _chooseDeck(context, deckService);
                        if (deck != null) {
                          final repeat = await _askRepeat(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SingleDeckGame(deck: deck, repeat: repeat),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: 'Multi Deck Mode',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DD0E1), Color(0xFFFFD180)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final decks = await _chooseMultiple(
                          context,
                          deckService,
                        );
                        if (decks.isNotEmpty) {
                          final repeat = await _askRepeat(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MultiDeckGame(decks: decks, repeat: repeat),
                            ),
                          );
                        }
                      },
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

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Future askDialog(BuildContext context, Widget child) =>
      showDialog(context: context, builder: (_) => child);

  Future<bool> _askRepeat(BuildContext context) async {
    return await askDialog(
      context,
      AlertDialog(
        title: const Text('Repeat words?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _chooseDeck(BuildContext context, DeckService ds) {
    return askDialog(
      context,
      SimpleDialog(
        title: const Text('Choose deck'),
        children: [
          for (final d in ds.decks)
            SimpleDialogOption(
              child: Text(d.name),
              onPressed: () => Navigator.pop(context, d),
            ),
        ],
      ),
    );
  }

  Future<List<Deck>> _chooseMultiple(
    BuildContext context,
    DeckService ds,
  ) async {
    final selected = <Deck>{};
    await askDialog(
      context,
      AlertDialog(
        title: const Text('Select decks'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final d in ds.decks)
                CheckboxListTile(
                  title: Text(d.name),
                  value: selected.contains(d),
                  onChanged: (val) => setState(
                    () => val! ? selected.add(d) : selected.remove(d),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selected.toList()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return selected.toList();
  }
}
