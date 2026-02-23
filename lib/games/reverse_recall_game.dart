import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class ReverseRecallGame extends StatefulWidget {
  final Deck deck;
  final AppTheme theme;
  const ReverseRecallGame({super.key, required this.deck, required this.theme});

  @override
  State<ReverseRecallGame> createState() => _ReverseRecallGameState();
}

class _ReverseRecallGameState extends State<ReverseRecallGame>
    with SingleTickerProviderStateMixin {
  late List<int> _currentIndices;
  late List<int> _delayed;
  int? _currentIndex;
  bool _showFront = false;
  bool finished = false;
  late AnimationController _flipController;
  final Random _rnd = Random();
  int _totalCards = 0;
  LinearGradient? _currentGradient;

  @override
  void initState() {
    super.initState();
    final cardsWithBacks = List.generate(
      widget.deck.words.length,
      (i) => i,
    ).where((i) => widget.deck.hasBack(i)).toList();
    _currentIndices = cardsWithBacks;
    _delayed = [];
    _totalCards = _currentIndices.length;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _nextCard();
  }

  void _nextCard() {
    if (_currentIndices.isEmpty && _delayed.isEmpty) {
      setState(() {
        finished = true;
        _currentIndex = null;
        _currentGradient = null;
      });
      return;
    }

    int next;
    if (_currentIndices.isNotEmpty) {
      next = _currentIndices.removeAt(_rnd.nextInt(_currentIndices.length));
    } else {
      next = _delayed.removeAt(0);
    }

    final gradient = widget.theme.isMinimalistic
        ? widget.theme.cardGradient
        : LinearGradient(
            colors: [
              Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200,
              Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    setState(() {
      _currentIndex = next;
      _showFront = false;
      _currentGradient = gradient;
      _flipController.reset();
    });
  }

  void _flipCard() {
    if (_currentIndex == null) return;
    if (!_showFront) {
      setState(() => _showFront = true);
      _flipController.forward();
    }
  }

  void _markGood() {
    _nextCard();
  }

  void _markAgain() {
    if (_currentIndex != null) {
      if (_currentIndices.length + _delayed.length > 0) {
        _delayed.add(_currentIndex!);
      } else {
        _currentIndices.add(_currentIndex!);
      }
    }
    _nextCard();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  double _getFontSize(String text) {
    if (text.length <= 5) return 50;
    if (text.length <= 10) return 40;
    if (text.length <= 15) return 30;
    return 28;
  }

  Widget _buildCard(String text, LinearGradient gradient) {
    final fontSize = _getFontSize(text);
    final textColor = widget.theme.primaryTextColor;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        minHeight: 80,
        maxWidth: 300,
        maxHeight: 200,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
    );
  }

  Widget _buildFlipCard() {
    if (_currentIndex == null || _currentGradient == null) {
      return const SizedBox();
    }

    final frontText = widget.deck.words[_currentIndex!];
    final backText = widget.deck.getBack(_currentIndex!) ?? '';

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * pi;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: angle < pi / 2
                    ? _buildCard(backText, _currentGradient!)
                    : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildCard(frontText, _currentGradient!),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remainingCards =
        _currentIndices.length + _delayed.length + (finished ? 0 : 1);

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
                      : _buildFlipCard(),
                ),
              ),
              if (!finished && _currentIndex != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _showFront ? '' : l10n.common_tapToReveal,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.theme.secondaryTextColor,
                    ),
                  ),
                ),
              if (!finished && _currentIndex != null && _showFront)
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
