import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game_service.dart';
import '../di.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class RecallWordGame extends StatefulWidget {
  final Deck deck;
  final AppTheme theme;
  const RecallWordGame({super.key, required this.deck, required this.theme});

  @override
  State<RecallWordGame> createState() => _RecallWordGameState();
}

class _RecallWordGameState extends State<RecallWordGame>
    with TickerProviderStateMixin {
  final game = getIt<GameService>();
  late List<String> _currentDeck;
  late List<String> _delayed;
  String currentWord = '';
  bool finished = false;
  late AnimationController _animController;
  final Random _rnd = Random();
  int _totalCards = 0;

  @override
  void initState() {
    super.initState();
    _currentDeck = List.from(widget.deck.words);
    _delayed = [];
    _totalCards = _currentDeck.length;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _nextWord();
  }

  void _nextWord() {
    if (_currentDeck.isEmpty && _delayed.isEmpty) {
      setState(() {
        finished = true;
        currentWord = '';
      });
      return;
    }

    String next = '';
    if (_currentDeck.isNotEmpty) {
      next = _currentDeck.removeAt(_rnd.nextInt(_currentDeck.length));
    } else if (_delayed.isNotEmpty) {
      next = _delayed.removeAt(0);
    }

    setState(() {
      currentWord = next;
      _animController.forward(from: 0);
    });
  }

  void _markGood() {
    _nextWord();
  }

  void _markAgain() {
    if (_currentDeck.length + _delayed.length > 0) {
      _delayed.add(currentWord);
    } else {
      _currentDeck.add(currentWord);
    }
    _nextWord();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  LinearGradient _randomGradient() {
    if (widget.theme.isModest) {
      return widget.theme.cardGradient;
    }
    final c1 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200;
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade300;
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  double _getFontSize(String text) {
    if (text.length <= 5) return 50;
    if (text.length <= 10) return 40;
    if (text.length <= 15) return 30;
    return 28;
  }

  Widget _buildCard(String text) {
    final fontSize = _getFontSize(text);
    final textColor = widget.theme.primaryTextColor;

    return ScaleTransition(
      scale: CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          minHeight: 80,
          maxWidth: 300,
          maxHeight: 200,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _randomGradient(),
          borderRadius: BorderRadius.circular(20),
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
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remainingCards =
        _currentDeck.length + _delayed.length + (finished ? 0 : 1);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.theme.primaryTextColor),
        title: Text(
          widget.deck.name,
          style: TextStyle(color: widget.theme.primaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!finished)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    l10n.game_cardsLeft(remainingCards, _totalCards),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.primaryTextColor,
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: finished
                      ? Text(
                          l10n.common_congratulations,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: widget.theme.primaryTextColor,
                          ),
                        )
                      : _buildCard(currentWord),
                ),
              ),
              if (!finished)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _markAgain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            l10n.common_again,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _markGood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            l10n.common_good,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (finished)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        l10n.common_finish,
                        style: TextStyle(
                          fontSize: 28,
                          color: widget.theme.buttonTextColor,
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
}
