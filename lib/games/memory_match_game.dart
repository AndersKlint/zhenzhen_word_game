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

  double _getFontSize(String text) {
    if (text.length <= 5) return 18;
    if (text.length <= 10) return 14;
    return 15;
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
        const padding = 48.0; // 16 top + 32 bottom
        const spacing = 8.0;
        const minCardSize = 50.0;

        final availableWidth = constraints.maxWidth - padding;
        final availableHeight = constraints.maxHeight - padding;
        final tileCount = _tiles.length;

        // Start with a reasonable column count based on tile count
        int startCols;
        if (tileCount <= 4) {
          startCols = 2;
        } else if (tileCount <= 6) {
          startCols = 3;
        } else if (tileCount <= 9) {
          startCols = 4;
        } else if (tileCount <= 16) {
          startCols = 6;
        } else {
          startCols = 8;
        }

        // Try from starting column count, adjusting based on available space
        int crossAxisCount = startCols.clamp(2, 8);

        // Try to fit with larger cards first (fewer columns)
        for (int cols = startCols; cols >= 2; cols--) {
          final rows = (tileCount / cols).ceil();
          final cardWidth = (availableWidth - (cols - 1) * spacing) / cols;
          final cardHeight = (availableHeight - (rows - 1) * spacing) / rows;
          final cardSize = cardWidth < cardHeight ? cardWidth : cardHeight;

          if (cardSize >= minCardSize) {
            crossAxisCount = cols;
            break;
          }
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: tileCount,
          itemBuilder: (context, index) => _buildTile(index),
        );
      },
    );
  }

  Widget _buildTile(int index) {
    final tile = _tiles[index];
    final isFlipped = tile.isFlipped || tile.isMatched;

    final backGradient = widget.theme.isModest
        ? widget.theme.cardGradient
        : LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: () => _flipTile(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isFlipped ? _getTileGradient(tile) : backGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(tile.isMatched ? 0 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isFlipped
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    tile.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getFontSize(tile.text),
                      fontWeight: FontWeight.bold,
                      color: widget.theme.primaryTextColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.help_outline,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
        ),
      ),
    );
  }

  LinearGradient _getTileGradient(_MemoryTile tile) {
    if (tile.isMatched) {
      return LinearGradient(
        colors: [Colors.green.shade200, Colors.green.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (widget.theme.isModest) {
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
