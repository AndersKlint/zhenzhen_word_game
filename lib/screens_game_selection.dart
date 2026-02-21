import 'package:flutter/material.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import 'package:zhenzhen_word_game/models.dart';
import 'package:zhenzhen_word_game/random_word_game.dart';
import 'package:zhenzhen_word_game/flip_card_game.dart';
import 'deck_service.dart';
import 'di.dart';
import 'recall_word_game.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deckService = getIt<DeckService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, 'Games'),
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
                      title: 'Recall Words',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecallWordGame(deck: deck),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: 'Flip Cards',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFF80DEEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck = await _chooseDeck(context, deckService);
                        if (deck != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlipCardGame(deck: deck),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: 'Random Words',
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
                                  RandomWordGame(decks: decks, repeat: repeat),
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

  Future<bool> _askRepeat(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Repeat words?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _chooseDeck(BuildContext context, DeckService ds) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose deck'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final d in ds.getUngroupedDecks())
                ListTile(
                  dense: true,
                  title: Text(d.name),
                  onTap: () => Navigator.pop(ctx, d),
                ),
              for (final group in ds.groups) ...[
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
                for (final d in ds.getGroupDecks(group.id))
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                    title: Text(d.name),
                    onTap: () => Navigator.pop(ctx, d),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Deck>> _chooseMultiple(
    BuildContext context,
    DeckService ds,
  ) async {
    final selected = <Deck>{};
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select decks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in ds.getUngroupedDecks())
                  CheckboxListTile(
                    dense: true,
                    title: Text(d.name),
                    value: selected.contains(d),
                    onChanged: (val) => setDialogState(
                      () => val! ? selected.add(d) : selected.remove(d),
                    ),
                  ),
                for (final group in ds.groups) ...[
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
                  for (final d in ds.getGroupDecks(group.id))
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    return selected.toList();
  }
}
