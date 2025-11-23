import 'package:flutter/material.dart';
import 'game_service.dart';
import 'di.dart';
import 'models.dart';
import 'dart:math';

class RecallWordGame extends StatefulWidget {
  final Deck deck;
  const RecallWordGame({super.key, required this.deck});

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
    final c1 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200;
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade400;
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
    return 24;
  }

  Widget _buildCard(String text) {
    final fontSize = _getFontSize(text);

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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingCards =
        _currentDeck.length + _delayed.length + (finished ? 0 : 1);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black87),
        title: Text(
          widget.deck.name,
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Counter
              if (!finished)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Cards left: $remainingCards / $_totalCards',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: finished
                      ? const Text(
                          "Congratulations! You cleared all the cards!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                          child: const Text(
                            "Again",
                            style: TextStyle(fontSize: 24, color: Colors.white),
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
                          child: const Text(
                            "Good",
                            style: TextStyle(fontSize: 24, color: Colors.white),
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
                        backgroundColor: Colors.pink.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Finish",
                        style: TextStyle(fontSize: 28, color: Colors.black87),
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
