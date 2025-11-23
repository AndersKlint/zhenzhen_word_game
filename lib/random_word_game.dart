import 'package:flutter/material.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import 'game_service.dart';
import 'di.dart';
import 'models.dart';
import 'dart:math';

class RandomWordGame extends StatefulWidget {
  final List<Deck> decks;
  final bool repeat;
  const RandomWordGame({super.key, required this.decks, required this.repeat});

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
          maxWidth: 250,
          maxHeight: 200,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(12),
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
    return Scaffold(
      appBar: buildAppBar(context, "Multi Deck (${widget.decks.length})"),
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
              Expanded(
                child: Center(
                  child: finished
                      ? const Text(
                          "All done!",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: current.map(_buildCard).toList(),
                          ),
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
                      backgroundColor: Colors.cyan.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: finished ? () => Navigator.pop(context) : _next,
                    child: Text(
                      finished ? "Finish" : "Next",
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.black87,
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
