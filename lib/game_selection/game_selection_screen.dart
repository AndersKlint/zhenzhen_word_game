import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../appbar.dart';
import '../models.dart';
import '../games/flip_card_game.dart';
import '../games/reverse_recall_game.dart';
import '../games/multiple_choice_game.dart';
import '../games/memory_match_game.dart';
import '../games/random_word_game.dart';
import '../games/recall_word_game.dart';
import '../theme/app_theme.dart';
import 'game_selection_controller.dart';
import 'widgets/game_card.dart';
import 'widgets/dialogs.dart';

class GameSelectionScreen extends StatelessWidget {
  final Deck? preselectedDeck;
  final AppTheme theme;

  const GameSelectionScreen({
    super.key,
    this.preselectedDeck,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = GameSelectionController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, l10n.gameSelection_title, theme: theme),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    preselectedDeck != null
                        ? l10n.gameSelection_playing(preselectedDeck!.name)
                        : l10n.gameSelection_selectMode,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildRecallFrontCard(context, l10n, controller),
                      const SizedBox(height: 24),
                      _buildRecallBothCard(context, l10n, controller),
                      const SizedBox(height: 24),
                      _buildRandomMultiCard(context, l10n, controller),
                      const SizedBox(height: 24),
                      _buildReverseRecallCard(context, l10n, controller),
                      const SizedBox(height: 24),
                      _buildMultipleChoiceCard(context, l10n, controller),
                      const SizedBox(height: 24),
                      _buildMemoryMatchCard(context, l10n, controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecallFrontCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_recallFront_title,
      description: l10n.game_recallFront_desc,
      gradient: theme.cardGradientAtIndex(0),
      onTap: () => _handleRecallFront(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleRecallFront(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final deck =
        preselectedDeck ?? await _chooseDeck(context, l10n, controller);
    if (deck != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecallWordGame(deck: deck, theme: theme),
        ),
      );
    }
  }

  Widget _buildRecallBothCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_recallBoth_title,
      description: l10n.game_recallBoth_desc,
      gradient: theme.cardGradientAtIndex(4),
      onTap: () => _handleRecallBoth(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleRecallBoth(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final deck =
        preselectedDeck ?? await _chooseDeck(context, l10n, controller);
    if (deck != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlipCardGame(deck: deck, theme: theme),
        ),
      );
    }
  }

  Widget _buildRandomMultiCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_randomMulti_title,
      description: l10n.game_randomMulti_desc,
      gradient: theme.cardGradientAtIndex(8),
      onTap: () => _handleRandomMulti(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleRandomMulti(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final initialSelection = preselectedDeck != null
        ? {preselectedDeck!}
        : <Deck>{};
    final decks = await _chooseMultiple(
      context,
      l10n,
      controller,
      initialSelection,
    );
    if (decks.isEmpty) return;

    final repeat = await _askRepeat(context, l10n);
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RandomWordGame(decks: decks, repeat: repeat, theme: theme),
      ),
    );
  }

  Widget _buildReverseRecallCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_reverseRecall_title,
      description: l10n.game_reverseRecall_desc,
      gradient: theme.cardGradientAtIndex(12),
      onTap: () => _handleReverseRecall(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleReverseRecall(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final deck =
        preselectedDeck ?? await _chooseDeck(context, l10n, controller);
    if (deck == null) return;

    if (deck.backs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.common_noBackText)));
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReverseRecallGame(deck: deck, theme: theme),
        ),
      );
    }
  }

  Widget _buildMultipleChoiceCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_multipleChoice_title,
      description: l10n.game_multipleChoice_desc,
      gradient: theme.cardGradientAtIndex(16),
      onTap: () => _handleMultipleChoice(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleMultipleChoice(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final deck =
        preselectedDeck ?? await _chooseDeck(context, l10n, controller);
    if (deck == null) return;

    if (deck.backs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.common_noBackText)));
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultipleChoiceGame(deck: deck, theme: theme),
        ),
      );
    }
  }

  Widget _buildMemoryMatchCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_memoryMatch_title,
      description: l10n.game_memoryMatch_desc,
      gradient: theme.cardGradientAtIndex(20),
      onTap: () => _handleMemoryMatch(context, l10n, controller),
      theme: theme,
    );
  }

  Future<void> _handleMemoryMatch(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    final deck =
        preselectedDeck ?? await _chooseDeck(context, l10n, controller);
    if (deck == null) return;

    if (deck.backs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.common_noBackText)));
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemoryMatchGame(deck: deck, theme: theme),
        ),
      );
    }
  }

  Future<Deck?> _chooseDeck(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    return await showDialog<Deck>(
      context: context,
      builder: (ctx) => ChooseDeckDialog(
        controller: controller,
        title: l10n.chooseDeck_title,
        onDeckSelected: (deck) {
          Navigator.pop(ctx, deck);
        },
      ),
    );
  }

  Future<List<Deck>> _chooseMultiple(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
    Set<Deck> initialSelection,
  ) async {
    return await showDialog<List<Deck>>(
          context: context,
          builder: (ctx) => ChooseMultipleDecksDialog(
            controller: controller,
            title: l10n.selectDecks_title,
            cancelText: l10n.dialog_cancel,
            okText: l10n.dialog_ok,
            initialSelection: initialSelection,
          ),
        ) ??
        [];
  }

  Future<bool> _askRepeat(BuildContext context, AppLocalizations l10n) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => RepeatDialog(
            title: l10n.repeatWords_title,
            noText: l10n.repeatWords_no,
            yesText: l10n.repeatWords_yes,
          ),
        ) ??
        false;
  }
}
