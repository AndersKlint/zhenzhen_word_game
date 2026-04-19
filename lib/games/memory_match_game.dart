import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class MemoryMatchGame extends StatefulWidget {
  final Deck deck;
  final AppTheme theme;
  const MemoryMatchGame({super.key, required this.deck, required this.theme});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame>
    with TickerProviderStateMixin {
  late List<_MemoryTile> _tiles;
  int? _flippedIndex;
  int _matches = 0;
  int _moves = 0;
  bool _canFlip = true;
  late AnimationController _flipController;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _setupTiles();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _setupTiles() {
    final cardsWithBacks = <int>[];
    for (int i = 0; i < widget.deck.words.length; i++) {
      if (widget.deck.hasBack(i)) {
        cardsWithBacks.add(i);
      }
    }

    _tiles = [];
    for (final cardIndex in cardsWithBacks) {
      _tiles.add(
        _MemoryTile(
          cardIndex: cardIndex,
          isFront: true,
          text: widget.deck.words[cardIndex],
        ),
      );
      _tiles.add(
        _MemoryTile(
          cardIndex: cardIndex,
          isFront: false,
          text: widget.deck.getBack(cardIndex)!,
        ),
      );
    }

    _tiles.shuffle(_rnd);
  }

  int get _totalPairs => _tiles.length ~/ 2;

  void _flipTile(int index) {
    if (!_canFlip) return;
    if (_tiles[index].isFlipped || _tiles[index].isMatched) return;

    setState(() {
      _tiles[index].isFlipped = true;
    });

    if (_flippedIndex == null) {
      _flippedIndex = index;
    } else {
      _moves++;
      _canFlip = false;

      final first = _tiles[_flippedIndex!];
      final second = _tiles[index];

      if (first.cardIndex == second.cardIndex &&
          first.isFront != second.isFront) {
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matches++;
          _flippedIndex = null;
          _canFlip = true;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            first.isFlipped = false;
            second.isFlipped = false;
            _flippedIndex = null;
            _canFlip = true;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFinished = _matches >= _totalPairs;

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
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(l10n.memory_moves, _moves),
                      _buildStat(
                        l10n.memory_matches,
                        '$_matches / $_totalPairs',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isFinished ? _buildFinishedScreen() : _buildGameGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: widget.theme.groupHeaderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: widget.theme.secondaryTextColor,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.theme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedScreen() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.memory_youWin,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: widget.theme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.memory_completedMoves(_moves),
            style: TextStyle(
              fontSize: 24,
              color: widget.theme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
    );
  }

  Widget _buildGameGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileCount = _tiles.length;

        const spacing = 8.0;
        const preferredSize = 400.0;
        const minSize = 160.0;

        final maxCols = (constraints.maxWidth / (preferredSize + spacing))
            .floor()
            .clamp(1, tileCount);
        final rows = (tileCount / maxCols).ceil();
        double cardSize = (constraints.maxHeight - (rows - 1) * spacing) / rows;
        cardSize = cardSize.clamp(minSize, preferredSize);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(tileCount, (index) {
                return SizedBox(
                  width: cardSize,
                  height: cardSize,
                  child: _buildTile(index, cardSize),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(int index, double cardSize) {
    final tile = _tiles[index];
    final text = tile.text;
    final isFlipped = tile.isFlipped || tile.isMatched;

    final backGradient = widget.theme.isMinimalistic
        ? widget.theme.cardGradient
        : LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final padding = cardSize * 0.08;
    final borderRadius = cardSize * 0.15;
    final iconSize = cardSize * 0.35;

    double baseFontSize = cardSize * 0.14;
    const double maxReduction = 10.0;
    double lengthFactor = text.length / 8;
    double fontReduction = (lengthFactor * 2.5).clamp(0, maxReduction);
    double fontSize = (baseFontSize - fontReduction).clamp(10.0, baseFontSize);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: cardSize - padding * 2);
    final needsScroll = textPainter.height > cardSize - padding * 2;

    return GestureDetector(
      onTap: () => _flipTile(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(
          minWidth: cardSize,
          minHeight: cardSize,
          maxWidth: cardSize,
          maxHeight: cardSize,
        ),
        decoration: BoxDecoration(
          gradient: isFlipped ? _getTileGradient(tile) : backGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: tile.isMatched ? 0 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isFlipped
              ? needsScroll
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.primaryTextColor,
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(padding),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: widget.theme.primaryTextColor,
                          ),
                        ),
                      )
              : Icon(
                  Icons.help_outline,
                  size: iconSize,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
        ),
      ),
    );
  }

  LinearGradient _getTileGradient(_MemoryTile tile) {
    if (tile.isMatched) {
      final correct = widget.theme.correctColor;
      return LinearGradient(
        colors: [
          correct.withValues(alpha: 0.3),
          correct.withValues(alpha: 0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (widget.theme.isMinimalistic) {
      return widget.theme.cardGradient;
    }
    final baseIndex = tile.cardIndex % Colors.primaries.length;
    final color = Colors.primaries[baseIndex];
    return LinearGradient(
      colors: [color.shade200, color.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _MemoryTile {
  final int cardIndex;
  final bool isFront;
  final String text;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryTile({
    required this.cardIndex,
    required this.isFront,
    required this.text,
  });
}
