import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import 'package:zhenzhen_word_game/models.dart';
import 'package:zhenzhen_word_game/random_word_game.dart';
import 'package:zhenzhen_word_game/flip_card_game.dart';
import 'package:zhenzhen_word_game/reverse_recall_game.dart';
import 'package:zhenzhen_word_game/multiple_choice_game.dart';
import 'package:zhenzhen_word_game/memory_match_game.dart';
import 'deck_service.dart';
import 'di.dart';
import 'recall_word_game.dart';

class GameSelectionScreen extends StatelessWidget {
  final Deck? preselectedDeck;
  const GameSelectionScreen({super.key, this.preselectedDeck});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deckService = getIt<DeckService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, l10n.gameSelection_title),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  preselectedDeck != null
                      ? l10n.gameSelection_playing(preselectedDeck!.name)
                      : l10n.gameSelection_selectMode,
                  style: const TextStyle(
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
                      title: l10n.game_recallFront_title,
                      description: l10n.game_recallFront_desc,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4DD0E1),
                          Color.fromARGB(255, 242, 196, 253),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck =
                            preselectedDeck ??
                            await _chooseDeck(context, deckService);
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
                      title: l10n.game_recallBoth_title,
                      description: l10n.game_recallBoth_desc,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCE93D8), Color(0xFF80DEEA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck =
                            preselectedDeck ??
                            await _chooseDeck(context, deckService);
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
                      title: l10n.game_randomMulti_title,
                      description: l10n.game_randomMulti_desc,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DD0E1), Color(0xFFFFD180)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final decks = await _chooseMultiple(
                          context,
                          deckService,
                          preselected: preselectedDeck,
                        );
                        if (decks.isNotEmpty) {
                          final repeat = await _askRepeat(context);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RandomWordGame(
                                  decks: decks,
                                  repeat: repeat,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: l10n.game_reverseRecall_title,
                      description: l10n.game_reverseRecall_desc,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck =
                            preselectedDeck ??
                            await _chooseDeck(context, deckService);
                        if (deck != null) {
                          if (deck.backs.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.common_noBackText)),
                              );
                            }
                            return;
                          }
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReverseRecallGame(deck: deck),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: l10n.game_multipleChoice_title,
                      description: l10n.game_multipleChoice_desc,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7E57C2), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck =
                            preselectedDeck ??
                            await _chooseDeck(context, deckService);
                        if (deck != null) {
                          if (deck.backs.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.common_noBackText)),
                              );
                            }
                            return;
                          }
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultipleChoiceGame(deck: deck),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildGameCard(
                      context,
                      title: l10n.game_memoryMatch_title,
                      description: l10n.game_memoryMatch_desc,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DB6AC), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        final deck =
                            preselectedDeck ??
                            await _chooseDeck(context, deckService);
                        if (deck != null) {
                          if (deck.backs.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.common_noBackText)),
                              );
                            }
                            return;
                          }
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryMatchGame(deck: deck),
                              ),
                            );
                          }
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
    required String description,
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
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
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
              const SizedBox(width: 12),
              _buildHelpIcon(context, description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpIcon(BuildContext context, String description) {
    return Tooltip(
      message: description,
      preferBelow: false,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 5),
      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
      child: const Icon(Icons.help_outline, size: 28, color: Colors.black87),
    );
  }

  Future<bool> _askRepeat(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.repeatWords_title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.repeatWords_no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.repeatWords_yes),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _chooseDeck(BuildContext context, DeckService ds) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chooseDeck_title),
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
    DeckService ds, {
    Deck? preselected,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = <Deck>{if (preselected != null) preselected};
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.selectDecks_title),
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
                  Builder(
                    builder: (context) {
                      final groupDecks = ds.getGroupDecks(group.id);
                      final allSelected =
                          groupDecks.isNotEmpty &&
                          groupDecks.every((d) => selected.contains(d));
                      final anySelected = groupDecks.any(
                        (d) => selected.contains(d),
                      );
                      final groupValue = allSelected
                          ? true
                          : (anySelected ? null : false);

                      return CheckboxListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 0,
                          right: 16,
                        ),
                        secondary: Icon(
                          Icons.folder,
                          color: Colors.purple.shade400,
                          size: 20,
                        ),
                        title: Text(
                          group.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: groupValue,
                        tristate: true,
                        onChanged: (val) => setDialogState(() {
                          if (val == true) {
                            for (final d in groupDecks) {
                              selected.add(d);
                            }
                          } else {
                            for (final d in groupDecks) {
                              selected.remove(d);
                            }
                          }
                        }),
                      );
                    },
                  ),
                  for (final d in ds.getGroupDecks(group.id))
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CheckboxListTile(
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
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialog_cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialog_ok),
            ),
          ],
        ),
      ),
    );
    return selected.toList();
  }
}
