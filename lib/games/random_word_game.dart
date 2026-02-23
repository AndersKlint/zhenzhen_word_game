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
    if (widget.theme.isMinimalistic) {
      return widget.theme.cardGradient;
    }
    if (widget.theme.isModern) {
      final c1 =
          Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade50;
      final c2 =
          Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade100;
      return LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final c1 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade100;
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200;
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildCard(String text, double cardSize) {
    final textColor = widget.theme.primaryTextColor;

    double baseFontSize = cardSize * 0.14;
    const double maxReduction = 5.0;
    double lengthFactor = text.length / 10;
    double fontReduction = (lengthFactor * 2).clamp(0, maxReduction);
    double fontSize = (baseFontSize - fontReduction).clamp(
      baseFontSize - maxReduction,
      baseFontSize,
    );

    return Container(
      constraints: BoxConstraints(
        minWidth: cardSize,
        minHeight: cardSize,
        maxWidth: cardSize,
        maxHeight: cardSize,
      ),
      decoration: BoxDecoration(
        gradient: _randomGradient(),
        borderRadius: BorderRadius.circular(cardSize * 0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                  child: finished
                      ? Center(
                          child: Text(
                            l10n.common_allDone,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.primaryTextColor,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final nonEmptyCards = current
                                .where((c) => c.isNotEmpty)
                                .toList();

                            final cardCount = nonEmptyCards.length;

                            const spacing = 8.0;
                            const preferredSize = 400.0;
                            const minSize = 200.0;

                            final maxCols =
                                (constraints.maxWidth /
                                        (preferredSize + spacing))
                                    .floor()
                                    .clamp(1, cardCount);
                            final rows = (cardCount / maxCols).ceil();
                            double cardSize =
                                (constraints.maxHeight - (rows - 1) * spacing) /
                                rows;
                            cardSize = cardSize.clamp(minSize, preferredSize);

                            return Center(
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                alignment: WrapAlignment.center,
                                children: List.generate(cardCount, (index) {
                                  return SizedBox(
                                    width: cardSize,
                                    height: cardSize,
                                    child: ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: _animController,
                                        curve: Curves.elasticOut,
                                      ),
                                      child: _buildCard(
                                        nonEmptyCards[index],
                                        cardSize,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
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
