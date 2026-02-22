import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import '../game_service.dart';
import '../di.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class RandomWordGame extends StatefulWidget {
  final List<Deck> decks;
  final bool repeat;
  final AppTheme theme;
  const RandomWordGame({
    super.key,
    required this.decks,
    required this.repeat,
    required this.theme,
  });

  @override
  State<RandomWordGame> createState() => _RandomWordGameState();
}

class _RandomWordGameState extends State<RandomWordGame>
    with TickerProviderStateMixin {
  final game = getIt<GameService>();
  List<String> current = [];
  bool finished = false;
  late AnimationController _animController;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    game.reset();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _next();
  }

  void _next() {
    setState(() {
      current = widget.decks.map((d) => game.draw(d, widget.repeat)).toList();
      finished = current.every((c) => c.isEmpty) && !widget.repeat;
      _animController.forward(from: 0);
    });
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
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade400;
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildCard(String text, double fontSize, double cardSize) {
    final textColor = widget.theme.isModest
        ? widget.theme.primaryTextColor
        : Colors.white;

    return Container(
      width: cardSize,
      height: cardSize,
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.all(cardSize * 0.08),
      decoration: BoxDecoration(
        gradient: _randomGradient(),
        borderRadius: BorderRadius.circular(cardSize * 0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
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

  ({double cardSize, double fontSize}) _calculateCardSize(
    int cardCount,
    double availableWidth,
    double availableHeight,
  ) {
    const spacing = 8.0;
    const minCardSize = 60.0;
    const maxCardSize = 120.0;

    // Start with a reasonable column count based on card count
    int startCols;
    if (cardCount <= 2) {
      startCols = 2;
    } else if (cardCount <= 4) {
      startCols = 3;
    } else if (cardCount <= 6) {
      startCols = 4;
    } else {
      startCols = 6;
    }

    // Try from starting column count, adjusting based on available space
    // Try larger cards first (fewer columns)
    for (int cols = startCols; cols >= 2; cols--) {
      final rows = (cardCount / cols).ceil();
      final cardWidth = (availableWidth - (cols - 1) * spacing) / cols;
      final cardHeight = (availableHeight - (rows - 1) * spacing) / rows;
      final cardSize = cardWidth < cardHeight ? cardWidth : cardHeight;

      if (cardSize >= minCardSize) {
        // Calculate font size based on card size
        final fontSizeRatio = cardSize / maxCardSize;
        double fontSize;
        if (cardCount <= 2) {
          fontSize = 32 * fontSizeRatio;
        } else if (cardCount <= 4) {
          fontSize = 24 * fontSizeRatio;
        } else if (cardCount <= 6) {
          fontSize = 18 * fontSizeRatio;
        } else {
          fontSize = 16 * fontSizeRatio;
        }
        fontSize = fontSize.clamp(10.0, 32.0);

        return (cardSize: cardSize, fontSize: fontSize);
      }
    }

    // Fallback to minimum size
    return (cardSize: minCardSize, fontSize: 10.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: buildAppBar(
        context,
        l10n.game_multiDeck(widget.decks.length),
        theme: widget.theme,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: finished
                        ? Text(
                            l10n.common_allDone,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.primaryTextColor,
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final cardCount = current
                                  .where((c) => c.isNotEmpty)
                                  .length;
                              // GridView has padding of 16 top + 24 bottom = 40
                              final availableHeight =
                                  constraints.maxHeight - 40;
                              final ({double cardSize, double fontSize})
                              sizing = _calculateCardSize(
                                cardCount,
                                constraints.maxWidth,
                                availableHeight,
                              );
                              final cols =
                                  (constraints.maxWidth / sizing.cardSize)
                                      .floor()
                                      .clamp(2, 6);

                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  24,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1.0,
                                    ),
                                itemCount: cardCount,
                                itemBuilder: (context, index) {
                                  final nonEmptyCards = current
                                      .where((c) => c.isNotEmpty)
                                      .toList();
                                  return ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: _animController,
                                      curve: Curves.elasticOut,
                                    ),
                                    child: _buildCard(
                                      nonEmptyCards[index],
                                      sizing.fontSize,
                                      sizing.cardSize,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: finished
                          ? () => Navigator.pop(context)
                          : _next,
                      child: Text(
                        finished ? l10n.common_finish : l10n.common_next,
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
      ),
    );
  }
}
