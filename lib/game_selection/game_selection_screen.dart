import 'package:flutter/material.dart';
import '../deck_service.dart';
import '../di.dart';
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

class GameSelectionScreen extends StatefulWidget {
  final List<Deck> preselectedDecks;
  final AppTheme theme;

  const GameSelectionScreen({
    super.key,
    this.preselectedDecks = const [],
    required this.theme,
  });

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  late final GameSelectionController _controller;
  late final List<Deck> _selectedDecks;

  @override
  void initState() {
    super.initState();
    _controller = GameSelectionController(deckService: getIt<DeckService>());
    _selectedDecks = List.of(widget.preselectedDecks);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(
        context,
        l10n.gameSelection_title,
        theme: widget.theme,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildSelectedDecksPanel(context, l10n),
              const SizedBox(height: 24),
              _buildRecallFrontCard(context, l10n, _controller),
              const SizedBox(height: 24),
              _buildRecallBothCard(context, l10n, _controller),
              const SizedBox(height: 24),
              _buildRandomMultiCard(context, l10n, _controller),
              const SizedBox(height: 24),
              _buildReverseRecallCard(context, l10n, _controller),
              const SizedBox(height: 24),
              _buildMultipleChoiceCard(context, l10n, _controller),
              const SizedBox(height: 24),
              _buildMemoryMatchCard(context, l10n, _controller),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDecksPanel(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.groupHeaderColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.theme.groupHeaderBorderColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.theme.cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gameSelection_selectedDecks,
            style: TextStyle(
              color: widget.theme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedDecks.isEmpty) ...[
            Text(
              l10n.gameSelection_addDecksHint,
              style: TextStyle(
                color: widget.theme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            _buildAddDeckButton(context, l10n),
          ] else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final deck in _selectedDecks) _buildDeckChip(deck),
                _buildAddDeckButton(context, l10n),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDeckChip(Deck deck) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.only(left: 14, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: widget.theme.selectedGamesListItemColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.groupHeaderBorderColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              deck.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.theme.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _removeDeck(deck),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 18,
                color: widget.theme.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDeckButton(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: widget.theme.playButtonColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _addDecks(context, l10n),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Icon(Icons.add, size: 20, color: widget.theme.buttonTextColor),
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
      gradient: widget.theme.cardGradientAtIndex(0),
      onTap: () => _handleRecallFront(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleRecallFront(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    await _openSingleDeckGame(
      context,
      l10n,
      controller,
      builder: (deck) => RecallWordGame(deck: deck, theme: widget.theme),
    );
  }

  Widget _buildRecallBothCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_recallBoth_title,
      description: l10n.game_recallBoth_desc,
      gradient: widget.theme.cardGradientAtIndex(4),
      onTap: () => _handleRecallBoth(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleRecallBoth(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    await _openSingleDeckGame(
      context,
      l10n,
      controller,
      builder: (deck) => FlipCardGame(deck: deck, theme: widget.theme),
    );
  }

  Widget _buildRandomMultiCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_randomMulti_title,
      description: l10n.game_randomMulti_desc,
      gradient: widget.theme.cardGradientAtIndex(8),
      onTap: () => _handleRandomMulti(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleRandomMulti(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    if (_selectedDecks.length < 2) {
      await _showNeedsMoreDecksDialog(context, l10n);
      return;
    }

    final repeat = await _askRepeat(context, l10n);
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RandomWordGame(
          decks: List.of(_selectedDecks),
          repeat: repeat,
          theme: widget.theme,
        ),
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
      gradient: widget.theme.cardGradientAtIndex(12),
      onTap: () => _handleReverseRecall(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleReverseRecall(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    await _openSingleDeckGame(
      context,
      l10n,
      controller,
      requiresBackText: true,
      builder: (deck) => ReverseRecallGame(deck: deck, theme: widget.theme),
    );
  }

  Widget _buildMultipleChoiceCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_multipleChoice_title,
      description: l10n.game_multipleChoice_desc,
      gradient: widget.theme.cardGradientAtIndex(16),
      onTap: () => _handleMultipleChoice(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleMultipleChoice(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    await _openSingleDeckGame(
      context,
      l10n,
      controller,
      requiresBackText: true,
      builder: (deck) => MultipleChoiceGame(deck: deck, theme: widget.theme),
    );
  }

  Widget _buildMemoryMatchCard(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) {
    return GameCard(
      title: l10n.game_memoryMatch_title,
      description: l10n.game_memoryMatch_desc,
      gradient: widget.theme.cardGradientAtIndex(20),
      onTap: () => _handleMemoryMatch(context, l10n, controller),
      theme: widget.theme,
    );
  }

  Future<void> _handleMemoryMatch(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller,
  ) async {
    await _openSingleDeckGame(
      context,
      l10n,
      controller,
      requiresBackText: true,
      builder: (deck) => MemoryMatchGame(deck: deck, theme: widget.theme),
    );
  }

  Future<void> _openSingleDeckGame(
    BuildContext context,
    AppLocalizations l10n,
    GameSelectionController controller, {
    required Widget Function(Deck deck) builder,
    bool requiresBackText = false,
  }) async {
    if (_selectedDecks.isEmpty) {
      await _showNeedsMoreDecksDialog(context, l10n);
      return;
    }

    final deck = controller.mergeDecks(
      _selectedDecks,
      name: _sessionDeckName(l10n),
    );

    if (requiresBackText && !controller.hasBackText(deck)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.common_noBackText)));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => builder(deck)));
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

  Future<void> _addDecks(BuildContext context, AppLocalizations l10n) async {
    final decks = await _chooseMultiple(
      context,
      l10n,
      _controller,
      _selectedDecks.toSet(),
    );
    if (!mounted || decks.isEmpty) {
      return;
    }

    setState(() {
      _selectedDecks
        ..clear()
        ..addAll(decks);
    });
  }

  void _removeDeck(Deck deck) {
    setState(() {
      _selectedDecks.removeWhere((candidate) => candidate.id == deck.id);
    });
  }

  String _sessionDeckName(AppLocalizations l10n) {
    if (_selectedDecks.length == 1) {
      return _selectedDecks.first.name;
    }
    return l10n.game_multiDeck(_selectedDecks.length);
  }

  Future<void> _showNeedsMoreDecksDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectDecks_title),
        content: Text(l10n.gameSelection_moreDecksRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialog_ok),
          ),
        ],
      ),
    );
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
