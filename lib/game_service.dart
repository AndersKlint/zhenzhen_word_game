import 'dart:math';
import 'models.dart';

class GameService {
  final Random _rnd = Random();
  final Set<int> used = {};

  void reset() => used.clear();

  String draw(Deck deck, bool repeat) {
    if (deck.words.isEmpty) return '';
    if (repeat) return deck.words[_rnd.nextInt(deck.words.length)];
    final available = List.generate(deck.words.length, (i) => i).where((i) => !used.contains(i)).toList();
    if (available.isEmpty) return '';
    final idx = available[_rnd.nextInt(available.length)];
    used.add(idx);
    return deck.words[idx];
  }
}
