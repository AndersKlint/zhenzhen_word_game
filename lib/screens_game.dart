import 'package:flutter/material.dart';
import 'package:zhenzhen_word_game/appbar.dart';
import 'game_service.dart';
import 'di.dart';
import 'models.dart';
import 'dart:math';

class SingleDeckGame extends StatefulWidget {
  final Deck deck;
  final bool repeat;
  const SingleDeckGame({super.key, required this.deck, required this.repeat});

  @override
  State<SingleDeckGame> createState() => _SingleDeckGameState();
}

class _SingleDeckGameState extends State<SingleDeckGame>
    with TickerProviderStateMixin {
  final game = getIt<GameService>();
  String current = '';
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
      current = game.draw(widget.deck, widget.repeat);
      finished = current.isEmpty && !widget.repeat;
      _animController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Generates a random gradient for each card
  LinearGradient _randomGradient() {
    final c1 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200;
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade400;
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildCard(String text) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _randomGradient(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              // outline
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.black,
                ),
              ),
              // fill
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            colors: [
              Color(0xFFF8BBD0),
              Color(0xFF4DD0E1),
            ], // darker pink → turquoise
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!finished) _buildCard(current),
            if (finished)
              const Text(
                "All done!",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: finished ? () => Navigator.pop(context) : _next,
                  child: Text(
                    finished ? "Finish" : "Next",
                    style: const TextStyle(fontSize: 28, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiDeckGame extends StatefulWidget {
  final List<Deck> decks;
  final bool repeat;
  const MultiDeckGame({super.key, required this.decks, required this.repeat});

  @override
  State<MultiDeckGame> createState() => _MultiDeckGameState();
}

class _MultiDeckGameState extends State<MultiDeckGame>
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

  Widget _buildCard(String text) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _randomGradient(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              // Outline
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.black,
                ),
              ),
              // Fill
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!finished)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: current.map(_buildCard).toList(),
                ),
              ),
            if (finished)
              const Text(
                "All done!",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    style: const TextStyle(fontSize: 28, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
