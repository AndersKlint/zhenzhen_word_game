import 'dart:math';
import 'models.dart';

class GameService {
  final Random _rnd = Random();
  final Map<String, Set<int>> _usedPerDeck = {};

  void reset() => _usedPerDeck.clear();

  String draw(Deck deck, bool repeat) {
    if (deck.words.isEmpty) return '';
    if (repeat) return deck.words[_rnd.nextInt(deck.words.length)];

    _usedPerDeck.putIfAbsent(deck.id, () => {});
    final used = _usedPerDeck[deck.id]!;
    final available = List.generate(
      deck.words.length,
      (i) => i,
    ).where((i) => !used.contains(i)).toList();
    if (available.isEmpty) return '';
    final idx = available[_rnd.nextInt(available.length)];
    used.add(idx);
    return deck.words[idx];
  }
}
